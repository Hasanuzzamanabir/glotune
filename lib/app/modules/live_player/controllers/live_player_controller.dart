import 'dart:async';
import 'dart:convert';
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
  
  final memberCount = 0.obs;
  final title = "".obs;
  final hostProfilePic = "".obs;
  final errorMessage = "".obs;

  final liveMessages = [].obs;
  Timer? _messagePollTimer;
  Timer? _memberPollTimer;

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
      
      // 2. Fetch Agora Token and App ID
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final tokenResponse = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}live/token/$roomId/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      String agoraToken = '';
      String agoraAppId = '';
      
      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        agoraToken = tokenData['agora_token'] ?? tokenData['token'] ?? '';
        agoraAppId = tokenData['agora_app_id'] ?? tokenData['app_id'] ?? tokenData['appId'] ?? '';
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
      
      // Enable video
      await engine.enableVideo();

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

      // 4. Join channel
      await engine.joinChannel(
        token: agoraToken.isNotEmpty ? agoraToken : '',
        channelId: roomId,
        uid: 0, // Let Agora assign a UID
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
        ),
      );

      isEngineInitialized.value = true;
      isLoading.value = false;

      // Start polling messages and members
      _messagePollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        fetchLiveMessages();
      });
      _memberPollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        fetchLiveMemberCount();
      });

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
      memberCount.value = data['member_count'] ?? 0;
      if (data['host'] is Map<String, dynamic>) {
        hostProfilePic.value = data['host']['profile_picture'] ?? '';
      }
    } else {
      print("Failed to fetch room details: ${response.statusCode}");
      throw Exception("Failed to load room");
    }
  }

  @override
  void onClose() {
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
        memberCount.value = data['count'] ?? 0;
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
        liveMessages.value = data['results'] ?? data;
      }
    } catch (e) {
      print("Exception fetching messages in LivePlayerController: $e");
    }
  }

  Future<void> sendLiveMessage(String message) async {
    if (message.trim().isEmpty) return;
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
        body: jsonEncode({"message": message.trim()}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Fetch messages immediately to show the new one
        await fetchLiveMessages();
      } else {
        print("Failed to send message: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception sending message in LivePlayerController: $e");
    }
  }

  Future<void> sendReaction(String reactionType) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    final userId = authService.currentUserId.value;

    if (token == null || userId == null) {
      Get.snackbar('Error', 'Please login to send reactions', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/reactions/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user': {
            'id': userId,
            'username': 'Viewer',
          },
          'reaction_type': reactionType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show local floating animation
        _reactionStreamController.add(reactionType);
      } else {
        print("Failed to send reaction: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error sending reaction: $e");
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
