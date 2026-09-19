import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';

class LivePlayerController extends GetxController {
  late final String roomId;
  late RtcEngine engine;
  
  final isLoading = true.obs;
  final isEngineInitialized = false.obs;
  
  // State for rendering remote users
  final remoteUids = <int>[].obs;
  
  // Co-host broadcaster state
  final isCohost = false.obs;
  final localUid = 0.obs;
  final isMicMuted = false.obs;
  final isCamOff = false.obs;
  final hasActiveInvitation = false.obs;
  final invitingHostName = "Host".obs;

  final memberCount = 0.obs;
  final title = "".obs;
  final hostProfilePic = "".obs;
  final errorMessage = "".obs;

  final liveMessages = [].obs;
  Timer? _messagePollTimer;
  Timer? _memberPollTimer;
  Timer? _invitePollTimer;

  // In-room WebSocket
  WebSocket? _chatWs;

  // Stream for floating reactions
  final _reactionStreamController = StreamController<String>.broadcast();
  Stream<String> get reactionStream => _reactionStreamController.stream;

  @override
  void onInit() {
    super.onInit();
    roomId = Get.arguments as String;
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Request permissions (though viewers don't strictly need mic/camera, it's good practice for live streaming apps)
    await [Permission.microphone, Permission.camera].request();

    try {
      // 1. Fetch room details
      await _fetchRoomDetails();
      
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      // Call join room endpoint on backend so viewer count and membership are updated
      try {
        await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/join/'),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        print("Warning: Failed to call backend join room: $e");
      }
      
      // 2. Fetch Agora Token and App ID
      final tokenResponse = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}live/token/$roomId/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      String agoraToken = '';
      String agoraAppId = '';
      int agoraUid = 0;
      
      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        agoraToken = tokenData['agora_token'] ?? tokenData['token'] ?? '';
        agoraAppId = tokenData['agora_app_id'] ?? tokenData['app_id'] ?? tokenData['appId'] ?? '';
        agoraUid = (tokenData['agora_uid'] is int
                ? tokenData['agora_uid'] as int
                : int.tryParse(tokenData['agora_uid']?.toString() ?? '')) ??
            (tokenData['uid'] is int
                ? tokenData['uid'] as int
                : int.tryParse(tokenData['uid']?.toString() ?? '')) ??
            0;
      } else {
        throw Exception("Failed to fetch token");
      }
      
      if (agoraAppId.isEmpty) {
        if (agoraToken.startsWith('006') && agoraToken.length >= 35) {
          agoraAppId = agoraToken.substring(3, 35);
        } else {
          agoraAppId = ApiConstants.agoraAppId;
        }
      }

      // 3. Initialize Engine
      engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      
      // We are joining as an audience member
      await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      
      // Enable video and audio
      await engine.enableVideo();
      await engine.enableAudio();

      // Register event handlers
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("Successfully joined channel: ${connection.channelId}");
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("Remote user joined: $remoteUid");
            if (!remoteUids.contains(remoteUid)) {
              remoteUids.add(remoteUid);
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print("Remote user left: $remoteUid");
            remoteUids.remove(remoteUid);
          },
          onError: (ErrorCodeType err, String msg) {
            print("Agora Error: $err, $msg");
          },
        ),
      );

      // 4. Join channel with auto subscription enabled
      await engine.joinChannel(
        token: agoraToken.isNotEmpty ? agoraToken : '',
        channelId: roomId,
        uid: agoraUid, // Use UID returned from backend token or 0
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      localUid.value = agoraUid;
      isEngineInitialized.value = true;
      isLoading.value = false;

      // Start polling messages and members
      fetchLiveMemberCount();
      fetchLiveMessages();
      checkCohostInvitations();

      _messagePollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        fetchLiveMessages();
      });
      _memberPollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        fetchLiveMemberCount();
      });
      _invitePollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        checkCohostInvitations();
      });

      // Also connect to in-room WebSocket for real-time invitation events
      _connectInRoomWebSocket();

    } catch (e) {
      print("Error initializing Agora: $e");
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> _fetchRoomDetails() async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;

    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await apiClient.get(
      Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      title.value = data['title'] ?? "Live Stream";
      memberCount.value = data['viewer_count'] ?? data['member_count'] ?? 0;
      if (data['host'] is Map<String, dynamic>) {
        hostProfilePic.value = data['host']['profile_picture'] ?? '';
      }
    } else {
      print("Failed to fetch room details: ${response.statusCode}");
      throw Exception("Failed to load room");
    }
  }

  void _connectInRoomWebSocket() {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      // Build WS URL from baseUrl
      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final wsUrl = '$wsScheme://${parsed.host}${parsed.hasPort ? ':${parsed.port}' : ''}/ws/live/$roomId/?token=${token ?? ''}';
      
      print("[LivePlayer WS] Connecting to: $wsUrl");
      WebSocket.connect(wsUrl).then((ws) {
        _chatWs = ws;
        print("[LivePlayer WS] Connected successfully");
        ws.listen((event) {
          try {
            final data = jsonDecode(event.toString());
            print("[LivePlayer WS Event]: $data");
            _handleWebSocketEvent(data);
          } catch (err) {
            print("[LivePlayer WS] Error parsing message: $err");
          }
        }, onError: (err) {
          print("[LivePlayer WS] Stream error: $err");
        }, onDone: () {
          print("[LivePlayer WS] Stream closed");
        });
      }).catchError((err) {
        print("[LivePlayer WS] Connect error: $err");
      });
    } catch (e) {
      print("[LivePlayer WS] Setup exception: $e");
    }
  }

  void _handleWebSocketEvent(Map<String, dynamic> data) {
    print("[LivePlayer] Processing event: $data");
    final type = data['type']?.toString();
    final action = data['action']?.toString();

    // Check invitation events
    if (type == 'cohost_invite' ||
        type == 'cohost_invitation' ||
        type == 'invite_cohost' ||
        type == 'cohost' ||
        type == 'invite' ||
        (type == 'stream_request' && (action == 'invite' || action == 'invited'))) {

      final targetId = data['target_user_id'] ?? data['user_id'] ?? data['recipient_id'];
      final authService = Get.find<AuthService>();
      final myId = authService.currentUserId.value;

      // If targetId is provided, ensure it is for this user
      if (targetId != null && myId != null && targetId.toString() != myId.toString()) {
        print("[LivePlayer] Invite is for user $targetId, my id is $myId - ignoring");
        return;
      }

      final hostName = data['host_username'] ?? data['username'] ?? 'Host';
      _triggerCohostInvitationPrompt(hostName.toString());
    } else if (type == 'stream_request' && action == 'approved') {
      acceptCohostInvitation();
    }
  }

  Future<void> checkCohostInvitations() async {
    // If already co-hosting or already has active dialog, skip
    if (isCohost.value || hasActiveInvitation.value) return;

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/cohost-invites/');
      final res = await apiClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List invites = [];
        if (data is List) {
          invites = data;
        } else if (data is Map && data['results'] is List) {
          invites = data['results'];
        }

        final currentUserId = authService.currentUserId.value;
        for (var inv in invites) {
          final targetUserId = inv['user_id'] ?? (inv['user'] is Map ? inv['user']['id'] : null);
          final status = inv['status']?.toString();
          if ((targetUserId == null || targetUserId == currentUserId) && (status == 'pending' || status == null)) {
            final hostName = inv['host_name'] ?? inv['host_username'] ?? 'Host';
            _triggerCohostInvitationPrompt(hostName.toString());
            break;
          }
        }
      }
    } catch (_) {
      // Endpoint may not be implemented on older versions; WS and message stream are primary
    }
  }

  void _triggerCohostInvitationPrompt(String hostName) {
    if (hasActiveInvitation.value || isCohost.value) return;
    hasActiveInvitation.value = true;
    invitingHostName.value = hostName;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E293B),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("🎉", style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Co-Host Invitation!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$hostName invited you to join this live broadcast as a co-host!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        hasActiveInvitation.value = false;
                        Get.back();
                      },
                      child: const Text("Decline"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        acceptCohostInvitation();
                      },
                      child: const Text("Accept & Go Live"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> acceptCohostInvitation() async {
    hasActiveInvitation.value = false;
    Get.snackbar(
      "Connecting...",
      "Upgrading you to co-host broadcaster...",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.indigoAccent,
      colorText: Colors.white,
    );

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      // 1. Call backend start-cohost-stream
      try {
        final startRes = await apiClient.patch(
          Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/start-cohost-stream/'),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        print("[LivePlayer] start-cohost-stream response: ${startRes.statusCode} - ${startRes.body}");
      } catch (e) {
        print("[LivePlayer] Warning calling start-cohost-stream: $e");
      }

      // 2. Fetch new Agora token with publisher role
      final tokenRes = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}live/token/$roomId/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      String pubToken = '';
      int pubUid = localUid.value;
      if (tokenRes.statusCode == 200) {
        final tokenData = jsonDecode(tokenRes.body);
        pubToken = tokenData['agora_token'] ?? tokenData['token'] ?? '';
        final parsedUid = (tokenData['agora_uid'] is int
            ? tokenData['agora_uid'] as int
            : int.tryParse(tokenData['agora_uid']?.toString() ?? '')) ??
            (tokenData['uid'] is int
                ? tokenData['uid'] as int
                : int.tryParse(tokenData['uid']?.toString() ?? ''));
        if (parsedUid != null && parsedUid != 0) {
          pubUid = parsedUid;
        }
      }

      // 3. Upgrade Agora Engine to Broadcaster and publish media tracks
      if (pubToken.isNotEmpty) {
        try {
          await engine.renewToken(pubToken);
        } catch (_) {}
      }

      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.enableVideo();
      await engine.enableAudio();
      await engine.startPreview();

      // Update Channel Media Options to publish camera and mic
      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      localUid.value = pubUid;
      isCohost.value = true;

      Get.snackbar(
        "Live!",
        "You are now broadcasting live as co-host!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("[LivePlayer] Error upgrading to co-host: $e");
      Get.snackbar("Error", "Failed to start co-host stream: $e");
    }
  }

  Future<void> toggleMic() async {
    isMicMuted.value = !isMicMuted.value;
    try {
      await engine.muteLocalAudioStream(isMicMuted.value);
    } catch (e) {
      print("Error toggling mic: $e");
    }
  }

  Future<void> toggleCamera() async {
    isCamOff.value = !isCamOff.value;
    try {
      await engine.muteLocalVideoStream(isCamOff.value);
    } catch (e) {
      print("Error toggling camera: $e");
    }
  }

  @override
  void onClose() {
    _invitePollTimer?.cancel();
    try {
      _chatWs?.close();
    } catch (_) {}

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/leave/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (_) {}

    try {
      engine.leaveChannel();
    } catch (e) {
      print("Agora leaveChannel error: $e");
    }
    try {
      engine.release();
    } catch (e) {
      print("Agora release error: $e");
    }
    _messagePollTimer?.cancel();
    _memberPollTimer?.cancel();
    _reactionStreamController.close();
    super.onClose();
  }

  Future<void> fetchLiveMemberCount() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/members/');
      final response = await apiClient.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int count = 0;
        if (data is Map) {
          if (data['results'] is List) {
            count = data['count'] ?? (data['results'] as List).length;
          } else if (data['members'] is List) {
            count = data['count'] ?? (data['members'] as List).length;
          } else if (data['data'] is List) {
            count = (data['data'] as List).length;
          } else {
            count = data['count'] ?? data['member_count'] ?? data['viewer_count'] ?? 0;
          }
        } else if (data is List) {
          count = data.length;
        }
        memberCount.value = count;
      }
    } catch (e) {
      print("Exception fetching member count: $e");
    }
  }

  Future<void> fetchLiveMessages() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/messages/');
      final response = await apiClient.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List msgList = [];
        if (data is Map) {
          if (data['results'] is List) {
            msgList = data['results'];
          } else if (data['messages'] is List) {
            msgList = data['messages'];
          } else if (data['data'] is List) {
            msgList = data['data'];
          }
        } else if (data is List) {
          msgList = data;
        }
        liveMessages.value = msgList;
      }
    } catch (e) {
      print("Exception fetching messages in LivePlayerController: $e");
    }
  }

  Future<void> sendLiveMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/send-message/');
      final response = await apiClient.post(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"message": text}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Fetch messages immediately to show the new one
        await fetchLiveMessages();
      } else {
        print("Failed to send message: ${response.statusCode} - ${response.body}");
        if (token == null && (response.statusCode == 401 || response.statusCode == 403)) {
          Get.snackbar('Login Required', 'Please log in to send comments in the stream.');
        }
      }
    } catch (e) {
      print("Exception sending message in LivePlayerController: $e");
    }
  }

  Future<void> sendReaction(String reactionType) async {
    // Show local floating animation immediately for responsive feedback
    _reactionStreamController.add(reactionType);

    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;

    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/reactions/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reaction_type': reactionType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Reaction '$reactionType' sent successfully");
      } else {
        print("Failed to send reaction: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error sending reaction: $e");
    }
  }

  Future<void> requestToStream() async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;

    if (token == null) {
      Get.snackbar('Login Required', 'Please log in to request to stream.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      final res = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/request-stream/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Request Sent', 'Your request to join the stream was sent to the host!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print("Request to stream failed: ${res.statusCode} - ${res.body}");
        Get.snackbar('Notice', 'Request sent to host.');
      }
    } catch (e) {
      print("Error sending request to stream: $e");
    }
  }

  void shareLive() {
    Share.share('Join my live stream on Glotune! https://glotune.com/live/$roomId');
  }

  Future<void> sendGift(String giftType, {int quantity = 1}) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;

    if (token == null) {
      Get.snackbar('Error', 'Please login to send gifts', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/send-gift/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'gift_type': giftType,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // close bottom sheet
        Get.snackbar('Success', 'Gift sent successfully!', colorText: Colors.white, backgroundColor: Colors.green);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            if (errorBody.containsKey('detail')) {
              Get.snackbar('Error', errorBody['detail'].toString(), backgroundColor: Colors.red, colorText: Colors.white);
            } else if (errorBody.containsKey('error')) {
              Get.snackbar('Error', errorBody['error'].toString(), backgroundColor: Colors.red, colorText: Colors.white);
            } else {
              Get.snackbar('Error', 'Failed to send gift: ${response.statusCode}', backgroundColor: Colors.red, colorText: Colors.white);
            }
          } else {
            Get.snackbar('Error', 'Failed to send gift: ${response.statusCode}', backgroundColor: Colors.red, colorText: Colors.white);
          }
        } catch (_) {
          Get.snackbar('Error', 'Failed to send gift: ${response.statusCode}', backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      print("Error sending gift: $e");
      Get.snackbar('Error', 'An error occurred while sending gift', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
