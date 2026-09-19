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
import 'package:glotune/app/core/services/notification_websocket_service.dart';
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
  final typingNotice = "".obs;
  Timer? _typingTimer;
  final temporaryNotice = "".obs;
  Timer? _temporaryNoticeTimer;
  Timer? _wsReconnectTimer;

  void _scheduleWsReconnect() {
    _wsReconnectTimer?.cancel();
    if (isClosed) return;
    _wsReconnectTimer = Timer(const Duration(seconds: 2), () {
      if (_chatWs == null) {
        print("[LivePlayer WS] Reconnecting socket...");
        _connectInRoomWebSocket();
      }
    });
  }

  void showTemporaryNotice(String message) {
    if (message.trim().isEmpty) return;
    temporaryNotice.value = message;
    _temporaryNoticeTimer?.cancel();
    _temporaryNoticeTimer = Timer(const Duration(seconds: 4), () {
      temporaryNotice.value = "";
    });
  }
  Timer? _messagePollTimer;

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
      hasActiveInvitation.value = false;

      // Connect to WebSocket
      _connectInRoomWebSocket();

      // Check if user came from a notification "Accept & Go Live" tap
      if (Get.isRegistered<NotificationWebSocketService>()) {
        final notifService = Get.find<NotificationWebSocketService>();
        if (notifService.hasPendingAutoAccept.value) {
          notifService.hasPendingAutoAccept.value = false;
          Future.delayed(const Duration(milliseconds: 600), () {
            acceptCohostInvitation();
          });
        }
      }
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

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';
      final primaryWsUrl = '$wsScheme://${parsed.host}$portStr/api/ws/live/$roomId/?token=${token ?? ''}';
      final fallbackWsUrl = '$wsScheme://${parsed.host}$portStr/ws/live/$roomId/?token=${token ?? ''}';

      void listenWs(WebSocket ws) {
        _chatWs = ws;
        print("[LivePlayer WS] Connected successfully to: ${ws.toString()}");
        ws.listen((event) {
          try {
            final data = jsonDecode(event.toString());
            print("[LivePlayer WS Event]: $data");
            if (data is Map<String, dynamic>) {
              _handleWebSocketEvent(data);
            }
          } catch (err) {
            print("[LivePlayer WS] Error parsing message: $err");
          }
        }, onError: (err) {
          print("[LivePlayer WS] Stream error: $err");
          _chatWs = null;
          _scheduleWsReconnect();
        }, onDone: () {
          print("[LivePlayer WS] Stream closed");
          _chatWs = null;
          _scheduleWsReconnect();
        });
      }

      print("[LivePlayer WS] Connecting to primary: $primaryWsUrl");
      WebSocket.connect(primaryWsUrl).then((ws) {
        listenWs(ws);
      }).catchError((err) {
        print("[LivePlayer WS] Primary connect error ($err), attempting fallback to: $fallbackWsUrl");
        WebSocket.connect(fallbackWsUrl).then((ws) {
          listenWs(ws);
        }).catchError((fallbackErr) {
          print("[LivePlayer WS] Fallback connect error: $fallbackErr");
        });
      });
    } catch (e) {
      print("[LivePlayer WS] Setup exception: $e");
    }
  }

  void _handleWebSocketEvent(Map<String, dynamic> data) {
    print("[LivePlayer] Processing event: $data");
    final type = data['type']?.toString();
    final action = data['action']?.toString();

    // 1. Message event
    if (type == 'message' || action == 'message') {
      final text = (data['message'] ?? data['text'] ?? data['content'])?.toString();
      if (text != null && text.trim().isNotEmpty) {
        final msgId = data['message_id'] ?? data['id'];
        final username = data['username'] ?? data['user']?['username'];
        final time = data['timestamp'] ?? data['created_at'];

        // Normalize message
        final normalized = <String, dynamic>{
          'id': msgId,
          'message_id': msgId,
          'message': text,
          'username': username ?? 'Viewer',
          'user_id': data['user_id'],
          'profile_picture': data['profile_picture'],
          'timestamp': time ?? DateTime.now().toIso8601String(),
          ...data,
        };

        final existingIndex = liveMessages.indexWhere((m) {
          if (m is Map) {
            final mId = m['message_id'] ?? m['id'];
            if (msgId != null && mId != null && msgId.toString() == mId.toString()) {
              return true;
            }
            final mText = (m['message'] ?? m['text'] ?? m['content'])?.toString();
            final mUser = m['username'] ?? m['user']?['username'];
            if (mText == text) {
              if (mUser == null || username == null || mUser == username) {
                return true;
              }
            }
          }
          return false;
        });

        if (existingIndex != -1) {
          final existing = liveMessages[existingIndex];
          if (existing is Map) {
            liveMessages[existingIndex] = {
              ...existing,
              ...normalized,
            };
          }
        } else {
          liveMessages.insert(0, normalized);
          print("[LivePlayer WS] Inserted message: $normalized");
        }
      }
    }

    // 2. Like, heart or reaction event
    else if (type == 'like' ||
        action == 'like' ||
        type == 'heart' ||
        action == 'heart' ||
        type == 'love' ||
        action == 'love' ||
        type == 'reaction' ||
        action == 'reaction') {
      final reactionName = (type == 'heart' || action == 'heart' || type == 'love' || action == 'love')
          ? 'heart'
          : (data['reaction_type']?.toString() ?? data['reaction']?.toString() ?? 'like');
      print("[LivePlayer WS] Incoming reaction event: $reactionName");
      _reactionStreamController.add(reactionName);
    }

    // 3. Gift event
    else if (type == 'gift') {
      final giftType = data['gift_type']?.toString() ?? 'gift';
      final quantity = data['quantity'] ?? 1;
      final sender = data['username'] ?? data['user']?['username'] ?? 'Someone';
      _reactionStreamController.add(giftType);
      // Also add as system message in chat
      liveMessages.insert(0, {
        'message': '🎁 $sender sent $quantity $giftType!',
        'user': {'username': 'System'},
        'is_system': true,
      });
    }

    // 4. Typing event
    else if (type == 'typing') {
      final isTyping = data['is_typing'] == true || data['is_typing'] == 'true';
      final username = data['username'] ?? data['user']?['username'] ?? 'Someone';
      if (isTyping) {
        typingNotice.value = "$username is typing...";
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          typingNotice.value = "";
        });
      } else {
        typingNotice.value = "";
      }
    }

    // 5. Room ended event
    else if (type == 'room_ended') {
      Get.snackbar(
        'Live Ended',
        data['message']?.toString() ?? 'The host has ended this live stream.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.currentRoute.contains('live') || Get.isDialogOpen == true) {
          Get.back();
        }
      });
    }

    // 6. Member action / room update
    else if (type == 'member_action') {
      final countVal = data['viewer_count'] ?? data['member_count'] ?? data['count'];
      if (countVal != null) {
        final parsed = int.tryParse(countVal.toString());
        if (parsed != null) {
          memberCount.value = parsed;
        }
      }

      final username = data['username'] ?? data['user']?['username'] ?? '';
      String noticeMsg = (data['message'] ?? data['text'] ?? '')?.toString().trim() ?? '';
      if (noticeMsg.isEmpty && action != null) {
        if (action == 'user_left') {
          noticeMsg = username.isNotEmpty ? '@$username left the LIVE' : 'A viewer left the LIVE';
        } else if (action == 'user_joined') {
          noticeMsg = username.isNotEmpty ? '@$username joined the LIVE' : 'A new viewer joined the LIVE';
        }
      }

      if (noticeMsg.isNotEmpty) {
        showTemporaryNotice(noticeMsg);

        // Also add to chat messages as system notification
        liveMessages.insert(0, {
          'message': noticeMsg,
          'type': 'member_action',
          'action': action,
          'is_system': true,
          'username': username,
          'user_id': data['user_id'],
          'profile_picture': data['profile_picture'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }

    // 7. Check cohost invitation events
    else if (type == 'cohost_invite' ||
        type == 'cohost_invitation' ||
        type == 'invite_cohost' ||
        type == 'cohost' ||
        type == 'invite' ||
        action == 'invite' ||
        action == 'invited' ||
        action == 'cohost_invite' ||
        action == 'cohost_invitation' ||
        action == 'invite_cohost' ||
        (type == 'stream_request' && (action == 'invite' || action == 'invited'))) {

      final authService = Get.find<AuthService>();
      int? myId = authService.currentUserId.value;

      if (myId == null && authService.accessToken.value != null) {
        try {
          final parts = authService.accessToken.value!.split('.');
          if (parts.length > 1) {
            var p64 = parts[1];
            while (p64.length % 4 != 0) {
              p64 += '=';
            }
            final map = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(p64))));
            final idVal = map['user_id'] ?? map['id'] ?? map['sub'] ?? map['pk'];
            if (idVal != null) {
              myId = int.tryParse(idVal.toString());
              authService.currentUserId.value = myId;
            }
          }
        } catch (_) {}
      }

      // Check explicit target recipient
      final targetId = data['target_user_id'] ??
          data['invited_user_id'] ??
          data['recipient_id'] ??
          data['target_id'] ??
          data['to_user_id'] ??
          (data['invited_user'] is Map ? data['invited_user']['id'] : data['invited_user']) ??
          (data['target_user'] is Map ? data['target_user']['id'] : data['target_user']);
      
      final userIdsList = data['user_ids'];

      // If targetId is provided and myId is known, verify it is meant for this user
      if (targetId != null && myId != null) {
        if (targetId.toString() != myId.toString()) {
          print("[LivePlayer] Invite is for user $targetId, my id is $myId - ignoring");
          return;
        }
      } else if (userIdsList is List && myId != null) {
        final includesMe = userIdsList.any((id) => id.toString() == myId.toString());
        if (!includesMe) {
          print("[LivePlayer] Invite list does not include my id $myId - ignoring");
          return;
        }
      }

      final hostName = data['host_username'] ?? data['username'] ?? 'Host';
      print("[LivePlayer] Received co-host invitation from $hostName for current user!");
      triggerCohostInvitationPrompt(hostName.toString());
    } else if ((type == 'notification' && data['notification_type'] == 'live_invitation') ||
        type == 'live_invitation' ||
        data['notification_type'] == 'live_invitation') {
      final hostName = data['sender_name'] ?? data['host_username'] ?? data['username'] ?? 'Host';
      final notifRoomId = data['room_id']?.toString();
      if (notifRoomId == null || notifRoomId.isEmpty || notifRoomId == roomId) {
        print("[LivePlayer] Received live_invitation notification from $hostName for room $roomId");
        triggerCohostInvitationPrompt(hostName.toString());
      }
    } else if ((type == 'stream_request' || action == 'stream_request') &&
        (action == 'approved' || data['status'] == 'approved')) {
      print("[LivePlayer] Stream request approved! Auto-accepting cohost...");
      acceptCohostInvitation();
    }
  }

  void triggerCohostInvitationPrompt(String hostName) {
    if (isCohost.value) {
      print("[LivePlayer] Already co-host, skipping prompt");
      return;
    }
    if (hasActiveInvitation.value) {
      print("[LivePlayer] Invitation dialog already active");
      return;
    }
    print("[LivePlayer] Displaying Co-Host Invitation dialog from: $hostName");
    hasActiveInvitation.value = true;
    invitingHostName.value = hostName;

    // Dismiss any active bottom sheet or transient dialog so the invitation prompt is visible
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    if (Get.isDialogOpen == true) {
      Get.back();
    }

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
                        hasActiveInvitation.value = false;
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
    _wsReconnectTimer?.cancel();
    _typingTimer?.cancel();
    _temporaryNoticeTimer?.cancel();
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
    _reactionStreamController.close();
    super.onClose();
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
      if (_chatWs != null) {
        final payload = jsonEncode({
          "action": "message",
          "message": text,
        });
        _chatWs!.add(payload);
        print("[LivePlayer WS] Message sent: $payload");
      } else {
        print("[LivePlayer WS] Socket not connected, attempting reconnect...");
        _connectInRoomWebSocket();
      }
    } catch (e) {
      print("[LivePlayer WS] Error sending message via WS: $e");
    }
  }

  void sendSocketTyping(bool isTyping) {
    try {
      if (_chatWs != null) {
        _chatWs!.add(jsonEncode({
          "action": "typing",
          "is_typing": isTyping,
        }));
      }
    } catch (e) {
      print("[LivePlayer WS] Error sending typing status: $e");
    }
  }

  Future<void> sendReaction(String reactionType) async {
    // Show local floating animation immediately for responsive feedback
    _reactionStreamController.add(reactionType);

    // Send action to WebSocket so all other viewers & host see the reaction
    try {
      if (_chatWs != null) {
        final actionToSend = (reactionType == 'heart' || reactionType == 'love') ? 'heart' : reactionType;
        _chatWs!.add(jsonEncode({
          "action": actionToSend,
          "reaction_type": reactionType,
        }));
      }
    } catch (e) {
      print("[LivePlayer WS] Error sending reaction: $e");
    }

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
      // 1. Send immediate real-time notification to host over WebSocket
      if (_chatWs != null) {
        final myId = authService.currentUserId.value;
        _chatWs!.add(jsonEncode({
          "type": "stream_request",
          "action": "requested",
          "room_id": roomId,
          "requester_id": myId,
          "user_id": myId,
        }));
      }

      // 2. Call backend request-stream endpoint
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
        Get.snackbar('Request Sent', 'Your request was sent to the host.',
            backgroundColor: Colors.indigoAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("Error sending request to stream: $e");
    }
  }

  void shareLive() {
    try {
      if (_chatWs != null) {
        _chatWs!.add(jsonEncode({
          "action": "share",
        }));
      }
    } catch (e) {
      print("[LivePlayer WS] Error sending share action: $e");
    }
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
        // Broadcast gift action over WebSocket to all participants
        try {
          if (_chatWs != null) {
            _chatWs!.add(jsonEncode({
              "action": "gift",
              "gift_type": giftType,
              "quantity": quantity,
            }));
          }
        } catch (wsErr) {
          print("[LivePlayer WS] Error broadcasting gift: $wsErr");
        }

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
