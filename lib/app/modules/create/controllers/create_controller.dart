import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/services/pip_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:glotune/app/data/models/category_model.dart';
import 'package:glotune/app/data/models/user_profile.dart';

class CreateController extends GetxController {
  final selectedTab = "Videos".obs;
  final tabs = ["Posts", "Shorts", "Videos", "Live"];
  
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  
  final isFlashOn = false.obs;
  final isFrontCamera = true.obs;
  final isRecording = false.obs;
  final isRecordingPaused = false.obs;
  final recordedSeconds = 0.obs;
  Timer? _recordingTimer;
  
  // Media selection
  final ImagePicker _picker = ImagePicker();
  final selectedMediaPath = "".obs;
  final selectedThumbnailPath = "".obs;
  
  // Post/Content Metadata
  final postTitle = "".obs;
  final postCaption = "".obs;
  final postCategory = Rxn<int>(); 
  final isPosting = false.obs;

  final categoriesList = <CategoryModel>[].obs;
  final isCategoriesLoading = false.obs;

  final videoTitle = "".obs;
  final videoDescription = "".obs;
  
  // Live Stream Settings
  final liveTitle = "".obs;
  
  // Agora Broadcaster State
  final String appId = "YOUR_AGORA_APP_ID"; // TODO: Use real App ID
  RtcEngine? liveEngine;
  final isLiveEngineInitialized = false.obs;
  final liveRoomId = "".obs;
  final liveMemberCount = 0.obs;
  final liveMembers = [].obs;
  final liveMessages = [].obs;
  final liveDurationSeconds = 0.obs;
  Timer? _memberPollTimer;
  Timer? _messagePollTimer;
  Timer? _liveDurationTimer;
  final userProfile = Rxn<UserProfile>();
  final streamPrivacy = "Public".obs;
  final latencyMode = "Normal".obs;
  final autoRotate = true.obs;
  final audioSettings = "Stereo".obs;
  
  void toggleStreamPrivacy() {
    if (streamPrivacy.value == "Public") {
      streamPrivacy.value = "Followers Only";
    } else if (streamPrivacy.value == "Followers Only") streamPrivacy.value = "Private";
    else streamPrivacy.value = "Public";
  }
  
  void toggleLatencyMode() {
    latencyMode.value = latencyMode.value == "Normal" ? "Low Latency" : "Normal";
  }
  
  void toggleAudioSettings() {
    audioSettings.value = audioSettings.value == "Stereo" ? "Mono" : "Stereo";
  }
// Live Game Sub-menu & Selection State
  final showGameOptions = false.obs;
  final selectedGameType = "Box battle".obs;
  final selectedLiveAction = "".obs;
  
  final gameOptionsList = [
    "Box battle",
    "1v1",
    "Quiz",
    "2v2 battle",
    "Karaoke",
  ];
  // Quiz Category State
  final selectedQuizCategory = "Corporate and Business".obs;
  final quizCategoriesList = [
    "Entertainment and Pop Culture",
    "Corporate and Business",
    "Sport and Athletics",
    "Media and Journalism",
    "Politics and Governance",
  ];

  void toggleGameMenu() {
    showGameOptions.value = !showGameOptions.value;
    if (showGameOptions.value) {
      selectedLiveAction.value = "Game";
    } else {
      selectedLiveAction.value = "";
    }
  }

  void clearLiveAction() {
    selectedLiveAction.value = "";
  }
  
  // Live Guests & Battles
  final allowGuests = true.obs;
  final guestLayout = "Grid".obs;
  final isSearchingBattle = false.obs;
  
  // Live Background
  final selectedLiveBackground = (-1).obs;
  
  // Live Detailed Settings
  final guestCount = 3.obs;
  final timeLimit = "45 mins".obs;
  final showLayout = true.obs;
  final saveEveryday = true.obs;
  final allowComments = true.obs;
  final selectedLayout = "Panel".obs; // Panel, Grid, Fixed panel, Fixed grid
  
  // Navigation within Create
  final currentStep = "Camera".obs; // Camera, EditPost, UploadVideo, LiveStream, ModeratorManage, MuteViewers, FilterComments
  
  // Moderation
  final moderators = <Map<String, String>>[
    {'name': 'Devon Lane', 'handle': '@devon', 'role': 'Moderator'},
    {'name': 'Leslie Alexander', 'handle': '@leslie_a', 'role': 'Moderator'},
    {'name': 'Jerome Bell', 'handle': '@jerome_b', 'role': 'Moderator'},
  ].obs;

  void setTab(String tab) {
    selectedTab.value = tab;
    if (tab == "Shorts" || tab == "Live" || tab == "Videos") {
      initCamera();
    } else if (tab == "Posts") {
      pickMediaFromGallery();
    }
  }
  
  Future<void> initCamera() async {
    if (isCameraInitialized.value) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar("Camera Not Found", "No cameras are available. Are you running on a simulator?", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      print("Camera init error: \$e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Start camera by default on Videos tab
    initCamera();
    fetchCategories();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}auth/profile/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userProfile.value = UserProfile.fromJson(data);
      }
    } catch (e) {
      print("Error fetching user profile in CreateController: $e");
    }
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}category/list/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        categoriesList.value = results.map((e) => CategoryModel.fromJson(e)).toList();
        if (categoriesList.isNotEmpty) {
          postCategory.value = categoriesList.first.id;
        }
      } else {
        print("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> createNewCategory(String name) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}category/create/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"name": name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newCategory = CategoryModel.fromJson(data);
        // We can just fetch all categories again to be safe and ensure lists match
        await fetchCategories();
        // And select the newly created one
        postCategory.value = newCategory.id;
        Get.snackbar("Success", "Category created!");
      } else {
        Get.snackbar("Error", "Failed to create category");
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
      print("Error creating category: $e");
    }
  }

  Future<void> updateCategory(int id, String newName) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final response = await apiClient.patch(
        Uri.parse('${ApiConstants.baseUrl}category/$id/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"name": newName}),
      );

      if (response.statusCode == 200) {
        await fetchCategories();
        Get.snackbar("Success", "Category updated!");
      } else {
        Get.snackbar("Error", "Failed to update category");
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
      print("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      var request = http.Request('DELETE', Uri.parse('${ApiConstants.baseUrl}category/$id/'));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await apiClient.send(request);

      if (response.statusCode == 204 || response.statusCode == 200) {
        await fetchCategories();
        if (postCategory.value == id) {
          postCategory.value = categoriesList.isNotEmpty ? categoriesList.first.id : null;
        }
        Get.snackbar("Success", "Category deleted!");
      } else {
        Get.snackbar("Error", "Failed to delete category");
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
      print("Error deleting category: $e");
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  void toggleFlash() async {
    if (!isCameraInitialized.value || cameraController == null) return;
    
    isFlashOn.value = !isFlashOn.value;
    try {
      if (isFlashOn.value) {
        await cameraController!.setFlashMode(FlashMode.torch);
      } else {
        await cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      print("Flash error: \$e");
    }
  }

  void toggleCamera() async {
    isFrontCamera.value = !isFrontCamera.value;
    if (!isCameraInitialized.value) return;

    try {
      final cameras = await availableCameras();
      final targetLens = isFrontCamera.value ? CameraLensDirection.front : CameraLensDirection.back;
      
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == targetLens,
        orElse: () => cameras.first,
      );

      final oldController = cameraController;
      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      
      await oldController?.dispose();
      await cameraController!.initialize();
      
      // Trigger UI rebuild
      isCameraInitialized.value = false;
      isCameraInitialized.value = true;
    } catch (e) {
      print("Camera switch error: $e");
    }
  }

  void _startTimer() {
    recordedSeconds.value = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isRecordingPaused.value) {
        recordedSeconds.value++;
      }
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<void> onShutterButtonPressed() async {
    if (!isCameraInitialized.value || cameraController == null) return;

    if (selectedTab.value == "Shorts" || selectedTab.value == "Videos") {
      if (isRecording.value) {
        // Stop recording
        try {
          final XFile video = await cameraController!.stopVideoRecording();
          isRecording.value = false;
          isRecordingPaused.value = false;
          _stopTimer();
          selectedMediaPath.value = video.path;
          navigateTo("UploadVideo");
        } catch (e) {
          print("Error stopping video recording: $e");
          isRecording.value = false;
          isRecordingPaused.value = false;
          _stopTimer();
        }
      } else {
        // Start recording
        try {
          await cameraController!.startVideoRecording();
          isRecording.value = true;
          isRecordingPaused.value = false;
          _startTimer();
        } catch (e) {
          print("Error starting video recording: $e");
        }
      }
    } else {
       // Take a picture
       try {
         final XFile image = await cameraController!.takePicture();
         selectedMediaPath.value = image.path;
         navigateTo("EditPost");
       } catch (e) {
         print("Error taking picture: $e");
       }
    }
  }

  Future<void> pauseRecording() async {
    if (!isRecording.value || cameraController == null) return;
    try {
      await cameraController!.pauseVideoRecording();
      isRecordingPaused.value = true;
    } catch (e) {
      print("Error pausing video: $e");
    }
  }

  Future<void> resumeRecording() async {
    if (!isRecording.value || cameraController == null) return;
    try {
      await cameraController!.resumeVideoRecording();
      isRecordingPaused.value = false;
    } catch (e) {
      print("Error resuming video: $e");
    }
  }

  Future<void> cancelRecording() async {
    if (!isRecording.value || cameraController == null) return;
    try {
      await cameraController!.stopVideoRecording();
    } catch (e) {}
    isRecording.value = false;
    isRecordingPaused.value = false;
    _stopTimer();
    recordedSeconds.value = 0;
  }

  Future<void> redoRecording() async {
    await cancelRecording();
    await onShutterButtonPressed();
  }

  Future<void> submitPost() async {
    String contentType = 'post';
    if (selectedTab.value == "Videos") {
      contentType = 'video';
    } else if (selectedTab.value == "Shorts") contentType = 'shorts';
    else if (selectedTab.value == "Live") contentType = 'live_stream';

    String titleToUse = contentType == 'post' ? postTitle.value : videoTitle.value;
    String descToUse = contentType == 'post' ? postCaption.value : videoDescription.value;

    if (titleToUse.isEmpty || descToUse.isEmpty) {
      Get.snackbar("Error", "Title and description are required.");
      return;
    }
    
    isPosting.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}content/create/');
      var request = http.MultipartRequest('POST', url);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add text fields
      request.fields['title'] = titleToUse;
      request.fields['description'] = descToUse;
      if (postCategory.value != null) {
        request.fields['category'] = postCategory.value.toString();
      }
      
      request.fields['content_type'] = contentType;
      
      // Attach media if selected
      if (selectedMediaPath.value.isNotEmpty) {
        final fieldName = contentType == 'post' ? 'thumbnail' : 'video';
        request.files.add(await http.MultipartFile.fromPath(fieldName, selectedMediaPath.value));
      }

      // Attach explicitly selected thumbnail if uploading a video/shorts/live
      if (selectedThumbnailPath.value.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', selectedThumbnailPath.value));
      }
      
      print("========== API REQUEST ==========");
      print("URL: \$url");
      print("Headers: \${request.headers}");
      print("Fields: \${request.fields}");
      print("Files: \${request.files.map((f) => '\${f.field}: \${f.filename}').toList()}");
      print("=================================");

      final response = await apiClient.send(request);
      final respStr = await response.stream.bytesToString();
      
      print("========== API RESPONSE =========");
      print("Status Code: \${response.statusCode}");
      print("Body: \$respStr");
      print("=================================");
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar("Success", "Content posted successfully!");
        postTitle.value = "";
        postCaption.value = "";
        videoTitle.value = "";
        videoDescription.value = "";
        selectedMediaPath.value = "";
        selectedThumbnailPath.value = "";
        currentStep.value = "Camera"; // Go back
      } else {
        Get.snackbar("Error", "Failed to post: \${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred.");
      print("Exception in submitPost: \$e");
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> startLiveRoom() async {
    if (liveTitle.value.isEmpty) {
      Get.snackbar("Error", "Please enter a live stream title");
      return;
    }
    
    isPosting.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/');
      
      final response = await apiClient.post(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "title": liveTitle.value,
          "availability": "public",
          "max_viewers": 0,
          "max_concurrent_streamers": 0,
          "private_stream_charge": 0
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Live room creation response: ${response.body}");
        final data = jsonDecode(response.body);
        // The API expects the UUID string (room_id) for subsequent calls
        liveRoomId.value = data['room_id']?.toString() ?? data['id']?.toString() ?? '';
        
        print("Live room created with ID: ${liveRoomId.value}");
        
        // Use the dedicated start endpoint
        try {
          await apiClient.patch(
            Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/start/'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"status": "live"}),
          );
        } catch (e) {
          print("Failed to call start endpoint: $e");
        }
        
        // Fetch Agora Token and App ID
        String? agoraToken;
        String? agoraAppId;
        int? uid;
        try {
          final tokenResponse = await apiClient.get(
            Uri.parse('${ApiConstants.baseUrl}live/token/${liveRoomId.value}/'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
          );
          if (tokenResponse.statusCode == 200) {
            final tokenData = jsonDecode(tokenResponse.body);
            // Based on the Swagger screenshot, the response is a LiveRoom object
            agoraToken = tokenData['agora_token'] ?? tokenData['token'];
            agoraAppId = tokenData['agora_app_id'] ?? tokenData['app_id'] ?? tokenData['appId'];
            uid = tokenData['agora_uid'] ?? tokenData['uid'];
          } else {
            print("Failed to fetch Agora token: ${tokenResponse.statusCode}");
            print("Response body: ${tokenResponse.body}");
          }
        } catch (e) {
          print("Error fetching Agora token: $e");
        }
        
        Get.snackbar("Success", "Live room created!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
        
        // Initialize Agora
        if (agoraToken != null && agoraAppId != null) {
          await _initLiveEngine(agoraToken, agoraAppId, liveRoomId.value, uid ?? 0);
        } else {
          Get.snackbar("Error", "Could not get streaming credentials.");
        }
        
        // Start polling member count and messages
        _memberPollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          fetchLiveMemberCount();
        });
        _messagePollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          fetchLiveMessages();
        });
        
        // Navigate to the live stream view
        navigateTo("LiveStream");
      } else {
        Get.snackbar("Error", "Failed to start live: ${response.statusCode}");
        print("Error starting live room: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred.");
      print("Exception in startLiveRoom: $e");
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> _initLiveEngine(String token, String appId, String channelId, int uid) async {
    print("Initializing Live Engine with:");
    print("AppID: $appId");
    print("Token: $token");
    print("Channel: $channelId");
    print("UID: $uid");

    if (appId.isEmpty) {
      Get.snackbar("Error", "Agora App ID is empty from server.");
      return;
    }

    // Release the flutter camera controller first so Agora can use the camera
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
      isCameraInitialized.value = false;
    }

    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    try {
      print("Creating engine...");
      liveEngine = createAgoraRtcEngine();
      
      print("Initializing engine...");
      await liveEngine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      
      print("Setting role...");
      await liveEngine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      print("Enabling video...");
      await liveEngine!.enableVideo();
      
      print("Starting preview...");
      await liveEngine!.startPreview();

      print("Joining channel...");
      await liveEngine!.joinChannel(
        token: token,
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );
      
      print("Successfully joined channel!");
      isLiveEngineInitialized.value = true;
      liveDurationSeconds.value = 0;
      _liveDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        liveDurationSeconds.value++;
      });
    } catch (e, stackTrace) {
      print("Error initializing live engine: $e");
      print("Stack trace: $stackTrace");
      Get.snackbar("Live Error", "Failed to initialize camera. Check App ID or permissions.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
      // Rollback to camera view
      _cleanupAndNavigateToCamera();
    }
  }

  final isMicMuted = false.obs;

  bool minimizeToPip(BuildContext context) {
    if (liveEngine == null || !isLiveEngineInitialized.value) return true;
    
    final pipService = Get.find<PipService>();
    pipService.showPip(
      context: context,
      engine: liveEngine!,
      onTap: restoreFromPip,
    );
    
    // Return true to allow the route to pop naturally
    return true;
  }

  void restoreFromPip() {
    final pipService = Get.find<PipService>();
    pipService.hidePip();
    
    // Navigate back to the /create route so the user can see the fullscreen view again
    Get.toNamed('/create');
    
    // Ensure the LiveStream step is visible
    navigateTo("LiveStream");
  }

  Future<void> toggleMic() async {
    isMicMuted.value = !isMicMuted.value;
    if (liveEngine != null) {
      try {
        await liveEngine!.muteLocalAudioStream(isMicMuted.value);
      } catch (e) {
        print("Error muting audio: $e");
      }
    }
  }

  Future<void> switchCamera() async {
    if (liveEngine != null) {
      try {
        await liveEngine!.switchCamera();
      } catch (e) {
        print("Error switching camera: $e");
      }
    }
  }

  Future<void> fetchLiveMemberCount() async {
    if (liveRoomId.value.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/members/');
      final response = await apiClient.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        liveMemberCount.value = data['count'] ?? 0;
        liveMembers.value = data['results'] ?? [];
      }
    } catch (e) {
      print("Exception fetching member count: $e");
    }
  }

  Future<void> fetchLiveMessages() async {
    if (liveRoomId.value.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/messages/');
      final response = await apiClient.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        liveMessages.value = data['results'] ?? data;
      }
    } catch (e) {
      print("Exception fetching messages: $e");
    }
  }

  Future<void> sendLiveMessage(String message) async {
    if (liveRoomId.value.isEmpty || message.trim().isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/send-message/');
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
      print("Exception sending message: $e");
    }
  }

  Future<void> updateLiveRoom(Map<String, dynamic> data) async {
    if (liveRoomId.value.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/');
      
      final response = await apiClient.patch(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Live room updated successfully: $data");
      } else {
        print("Failed to update live room: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception in updateLiveRoom: $e");
    }
  }

  Future<void> endLiveStream() async {
    final String currentRoomId = liveRoomId.value;
    Map<String, dynamic>? stats;
    
    // Stop the engine and UI immediately so the user doesn't feel stuck
    if (liveEngine != null) {
      try {
        await liveEngine!.leaveChannel();
      } catch (e) {
        print("Agora leaveChannel error: $e");
      }
      try {
        await liveEngine!.release();
      } catch (e) {
        print("Agora release error: $e");
      }
      liveEngine = null;
    }
    _memberPollTimer?.cancel();
    _messagePollTimer?.cancel();
    isLiveEngineInitialized.value = false;
    
    // Clean up and route back to camera
    _cleanupAndNavigateToCamera();

    if (currentRoomId.isNotEmpty) {
      try {
        final authService = Get.find<AuthService>();
        final token = authService.accessToken.value;
        final endUrl = Uri.parse('${ApiConstants.baseUrl}live/rooms/$currentRoomId/end/');
        
        final response = await apiClient.patch(
          endUrl,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}),
        );
        
        if (response.statusCode == 200) {
          print("Live stream ended successfully on backend.");
          
          // Fetch stats
          try {
            final statsUrl = Uri.parse('${ApiConstants.baseUrl}live/rooms/$currentRoomId/stats/');
            final statsResponse = await apiClient.get(
              statsUrl,
              headers: {if (token != null) 'Authorization': 'Bearer $token'},
            );
            if (statsResponse.statusCode == 200) {
              stats = jsonDecode(statsResponse.body);
            }
          } catch (e) {
            print("Exception fetching stats: $e");
          }
        } else {
          print("Failed to end live stream: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        print("Exception in endLiveStream: $e");
      }
    }

    if (stats != null) {
      _showLiveStatsDialog(stats);
    }
  }

  void _showLiveStatsDialog(Map<String, dynamic> stats) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Live Stream Ended", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildStatRow(Icons.visibility, "Total Views", stats['total_views']?.toString() ?? "0"),
              const SizedBox(height: 16),
              _buildStatRow(Icons.group, "Peak Viewers", stats['peak_viewers']?.toString() ?? "0"),
              const SizedBox(height: 16),
              _buildStatRow(Icons.chat, "Total Messages", stats['total_messages']?.toString() ?? "0"),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Get.back(); // close dialog
                  },
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _cleanupAndNavigateToCamera() {
    liveTitle.value = "";
    liveRoomId.value = "";
    liveMemberCount.value = 0;
    liveDurationSeconds.value = 0;
    liveMembers.clear();
    liveMessages.clear();
    _liveDurationTimer?.cancel();
    navigateTo("Camera");
    initCamera(); // Restore flutter camera
  }

  Future<void> deleteLiveRoom() async {
    if (liveRoomId.value.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/');
      
      final response = await apiClient.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print("Live room deleted successfully.");
        Get.snackbar("Deleted", "Live room was deleted.");
      } else {
        print("Failed to delete live room: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception in deleteLiveRoom: $e");
    } finally {
      // Clean up engine anyway
      Get.find<PipService>().hidePip();
      if (liveEngine != null) {
        try {
          await liveEngine!.leaveChannel();
        } catch (e) {
          print("Agora leaveChannel error: $e");
        }
        try {
          await liveEngine!.release();
        } catch (e) {
          print("Agora release error: $e");
        }
        liveEngine = null;
      }
      _memberPollTimer?.cancel();
      _messagePollTimer?.cancel();
      isLiveEngineInitialized.value = false;
      
      Get.delete<CreateController>(force: true);
      _cleanupAndNavigateToCamera();
    }
  }

  final timerSeconds = 0.obs;

  void toggleTimer() {
    if (timerSeconds.value == 0) {
      timerSeconds.value = 3;
      Get.snackbar("Timer", "Timer set to 3 seconds", snackPosition: SnackPosition.TOP);
    } else if (timerSeconds.value == 3) {
      timerSeconds.value = 10;
      Get.snackbar("Timer", "Timer set to 10 seconds", snackPosition: SnackPosition.TOP);
    } else {
      timerSeconds.value = 0;
      Get.snackbar("Timer", "Timer off", snackPosition: SnackPosition.TOP);
    }
  }

  final selectedEffect = "None".obs;
  final selectedMusic = "None".obs;
  
  void openEffects() {
    // Handled by the View
  }

  void openMusic() {
    // Handled by the View
  }

  void navigateTo(String step) => currentStep.value = step;

  Future<void> pickMediaFromGallery() async {
    // Reset thumbnail on new media pick
    selectedThumbnailPath.value = "";
    if (selectedTab.value == "Posts") {
      final XFile? media = await _picker.pickMedia();
      if (media != null) {
        selectedMediaPath.value = media.path;
        final lowerPath = media.path.toLowerCase();
        final isVideo = lowerPath.endsWith('.mp4') || lowerPath.endsWith('.mov') || lowerPath.endsWith('.avi') || lowerPath.endsWith('.mkv');
        
        if (isVideo) {
          navigateTo("UploadVideo");
        } else {
          navigateTo("EditPost");
        }
      }
    } else if (selectedTab.value == "Shorts" || selectedTab.value == "Videos") {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        selectedMediaPath.value = video.path;
        navigateTo("UploadVideo");
      }
    }
  }
  Future<void> pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedThumbnailPath.value = image.path;
    }
  }
}
