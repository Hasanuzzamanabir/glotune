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
  final liveTitleController = TextEditingController();
  
  // Agora Broadcaster State
  final String appId = ApiConstants.agoraAppId;
  RtcEngine? liveEngine;
  final isLiveEngineInitialized = false.obs;
  final liveRoomId = "".obs;
  final liveRoomData = Rxn<Map<String, dynamic>>();
  final liveMemberCount = 0.obs;
  final liveMembers = <dynamic>[].obs;
  final liveMessages = <dynamic>[].obs;
  final liveDurationSeconds = 0.obs;
  Timer? _memberPollTimer;
  Timer? _messagePollTimer;
  Timer? _liveDurationTimer;
  final userProfile = Rxn<UserProfile>();
  final streamPrivacy = "Public".obs;
  final latencyMode = "Normal".obs;
  final autoRotate = true.obs;
  final audioSettings = "Stereo".obs;
  final allowComments = true.obs;
  final selectedLayout = "Panel".obs;
  
  void toggleStreamPrivacy() {
    if (streamPrivacy.value == "Public") {
      streamPrivacy.value = "Followers Only";
    } else if (streamPrivacy.value == "Followers Only") {
      streamPrivacy.value = "Private";
    } else {
      streamPrivacy.value = "Public";
    }
    print("[DEBUG LIVE] Stream privacy toggled to: ${streamPrivacy.value}");
    if (liveRoomId.value.isNotEmpty) {
      updateLiveRoom({'availability': streamPrivacy.value.toLowerCase()});
    }
  }
  
  void toggleLatencyMode() {
    latencyMode.value = latencyMode.value == "Normal" ? "Low Latency" : "Normal";
    print("[DEBUG LIVE] Latency mode toggled to: ${latencyMode.value}");
  }
  
  void toggleAudioSettings() {
    audioSettings.value = audioSettings.value == "Stereo" ? "Mono" : "Stereo";
    print("[DEBUG LIVE] Audio settings toggled to: ${audioSettings.value}");
  }

  void toggleComments(bool val) {
    allowComments.value = val;
    print("[DEBUG LIVE] Allow comments toggled to: $val");
    if (liveRoomId.value.isNotEmpty) {
      updateLiveRoom({'allow_comments': val});
    }
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
  final isMuteViewers = false.obs;
  
  // Navigation within Create
  final currentStep = "Camera".obs; // Camera, EditPost, UploadVideo, LiveStream, ModeratorManage, MuteViewers, FilterComments
  
  // Moderation - dynamic list of moderators
  final moderators = <Map<String, dynamic>>[].obs;

  void setLayout(String layout) {
    selectedLayout.value = layout;
    print("[DEBUG LIVE] Layout switched to: $layout");
    if (liveRoomId.value.isNotEmpty) {
      updateLiveRoom({'layout': layout});
    }
  }

  void toggleMuteViewers(bool val) {
    isMuteViewers.value = val;
    print("[DEBUG LIVE] Mute viewers set to: $val");
    if (liveRoomId.value.isNotEmpty) {
      updateLiveRoom({'mute_viewers': val});
    }
  }

  Future<void> toggleModerator(dynamic member, bool makeModerator) async {
    final user = member is Map && member['user'] is Map ? member['user'] : (member is Map ? member : {});
    final userId = user['id'] ?? (member is Map ? member['id'] : null);
    final name = user['full_name'] ?? user['username'] ?? user['name'] ?? 'User';
    final handle = user['username'] != null ? '@${user['username']}' : '';
    final avatar = user['profile_picture'] ?? user['avatar'];

    print("[DEBUG LIVE] toggleModerator: userId=$userId, name=$name, makeModerator=$makeModerator");

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (liveRoomId.value.isNotEmpty && userId != null) {
        final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/moderators/');
        if (makeModerator) {
          final res = await apiClient.post(
            url,
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'user_id': userId}),
          );
          print("[DEBUG LIVE] Add moderator API [${res.statusCode}]: ${res.body}");
        } else {
          final res = await apiClient.delete(
            Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/moderators/$userId/'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
          );
          print("[DEBUG LIVE] Remove moderator API [${res.statusCode}]: ${res.body}");
        }
      }
    } catch (e) {
      print("[DEBUG LIVE] toggleModerator API error: $e");
    }

    if (makeModerator) {
      if (!moderators.any((m) => (m['id'] != null && m['id'] == userId) || m['name'] == name)) {
        moderators.add({
          'id': userId,
          'name': name,
          'handle': handle,
          'avatar': avatar,
          'role': 'Moderator',
        });
      }
      Get.snackbar("Moderator", "$name is now a moderator", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
    } else {
      moderators.removeWhere((m) => (m['id'] != null && m['id'] == userId) || m['name'] == name);
      Get.snackbar("Moderator", "$name removed from moderators", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
    }
  }

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
    liveTitleController.dispose();
    _recordingTimer?.cancel();
    _memberPollTimer?.cancel();
    _messagePollTimer?.cancel();
    _liveDurationTimer?.cancel();
    cameraController?.dispose();
    if (liveEngine != null) {
      liveEngine!.leaveChannel();
      liveEngine!.release();
    }
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
    if (isPosting.value) return;

    final enteredTitle = (liveTitleController.text.isNotEmpty
            ? liveTitleController.text
            : liveTitle.value)
        .trim();
    final streamTitle = enteredTitle.isEmpty ? "Live Stream" : enteredTitle;

    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Login Required",
        "Please log in to start a live stream.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    // Ensure host profile is dynamically fetched
    if (userProfile.value == null) {
      print("[DEBUG LIVE] Fetching host user profile before starting live...");
      await fetchUserProfile();
    }

    isPosting.value = true;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/');
      print("[DEBUG LIVE] ================= START LIVE ROOM =================");
      print("[DEBUG LIVE] URL: $url");
      print("[DEBUG LIVE] Title: $streamTitle");
      print("[DEBUG LIVE] Host Profile: ${userProfile.value?.fullName} (${userProfile.value?.email})");

      final response = await apiClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "title": streamTitle,
        }),
      );

      print("[DEBUG LIVE] Create Room Status: ${response.statusCode}");
      print("[DEBUG LIVE] Create Room Response: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          liveRoomData.value = data;
        }
        liveTitle.value = data['title']?.toString() ?? streamTitle;
        liveRoomId.value =
            data['room_id']?.toString() ?? data['id']?.toString() ?? '';

        print("[DEBUG LIVE] Room created successfully! Room UUID: ${liveRoomId.value}");

        // Start the stream on backend (supports PUT or PATCH /live/rooms/{room_id}/start/)
        try {
          final startUrl = Uri.parse(
              '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/start/');
          print("[DEBUG LIVE] Calling start stream endpoint: $startUrl");
          final startRes = await apiClient.put(
            startUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"status": "live"}),
          );
          print("[DEBUG LIVE] PUT /start/ response: ${startRes.statusCode} - ${startRes.body}");
          if (startRes.statusCode != 200 && startRes.statusCode != 204) {
            final patchRes = await apiClient.patch(
              startUrl,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({"status": "live"}),
            );
            print("[DEBUG LIVE] PATCH /start/ response: ${patchRes.statusCode} - ${patchRes.body}");
          }
        } catch (e) {
          print("[DEBUG LIVE] Start endpoint warning: $e");
        }

        // Extract Agora token and credentials from room response
        String? agoraToken =
            data['agora_token']?.toString() ?? data['token']?.toString();
        String? agoraAppId = data['agora_app_id']?.toString() ??
            data['app_id']?.toString() ??
            data['appId']?.toString();
        int uid = (data['host'] is int
                ? data['host'] as int
                : int.tryParse(data['host']?.toString() ?? '')) ??
            0;

        print("[DEBUG LIVE] Initial Agora Token: ${agoraToken != null ? (agoraToken.length > 25 ? agoraToken.substring(0, 25) + '...' : agoraToken) : 'none'}");
        print("[DEBUG LIVE] Initial App ID: $agoraAppId, Host UID: $uid");

        // Fallback to fetch token if not in create room response
        if (agoraToken == null || agoraToken.isEmpty) {
          try {
            final tokenUrl = Uri.parse(
                '${ApiConstants.baseUrl}live/token/${liveRoomId.value}/');
            print("[DEBUG LIVE] Fetching Agora token fallback from: $tokenUrl");
            final tokenResponse = await apiClient.get(
              tokenUrl,
              headers: {
                'Authorization': 'Bearer $token',
              },
            );
            print("[DEBUG LIVE] Fallback Token response: ${tokenResponse.statusCode} - ${tokenResponse.body}");
            if (tokenResponse.statusCode == 200) {
              final tokenData = jsonDecode(tokenResponse.body);
              agoraToken = tokenData['agora_token']?.toString() ??
                  tokenData['token']?.toString();
              agoraAppId ??= tokenData['agora_app_id']?.toString() ??
                  tokenData['app_id']?.toString() ??
                  tokenData['appId']?.toString();
              if (uid == 0) {
                uid = (tokenData['agora_uid'] is int
                        ? tokenData['agora_uid'] as int
                        : int.tryParse(
                            tokenData['agora_uid']?.toString() ?? '')) ??
                    (tokenData['uid'] is int
                        ? tokenData['uid'] as int
                        : int.tryParse(tokenData['uid']?.toString() ?? '')) ??
                    0;
              }
            }
          } catch (e) {
            print("[DEBUG LIVE] Error fetching fallback token: $e");
          }
        }

        // Resolve Agora App ID dynamically
        if (agoraAppId == null || agoraAppId.isEmpty) {
          if (agoraToken != null &&
              agoraToken.startsWith('006') &&
              agoraToken.length >= 35) {
            agoraAppId = agoraToken.substring(3, 35);
            print("[DEBUG LIVE] Resolved Agora App ID from token prefix: $agoraAppId");
          } else {
            agoraAppId = ApiConstants.agoraAppId;
            print("[DEBUG LIVE] Resolved Agora App ID from ApiConstants: $agoraAppId");
          }
        }

        Get.snackbar("Success", "Live room created: ${liveTitle.value}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.black);

        // Initialize Agora
        if (agoraToken != null &&
            agoraToken.isNotEmpty &&
            agoraAppId.isNotEmpty) {
          await _initLiveEngine(agoraToken, agoraAppId, liveRoomId.value, uid);
        } else {
          Get.snackbar("Error", "Could not get streaming credentials.");
          print("[DEBUG LIVE] Failed: Missing streaming credentials");
        }

        // Fetch initial dynamic members & messages
        await fetchLiveMemberCount();
        await fetchLiveMessages();

        // Start dynamic polling
        _memberPollTimer?.cancel();
        _memberPollTimer =
            Timer.periodic(const Duration(seconds: 5), (timer) {
          fetchLiveMemberCount();
        });
        _messagePollTimer?.cancel();
        _messagePollTimer =
            Timer.periodic(const Duration(seconds: 2), (timer) {
          fetchLiveMessages();
        });

        // Navigate to the live stream view
        navigateTo("LiveStream");
      } else {
        Get.snackbar("Error", "Failed to start live: ${response.statusCode}");
        print("[DEBUG LIVE] Error starting live room: ${response.statusCode} - ${response.body}");
      }
    } catch (e, stack) {
      Get.snackbar("Error", "An unexpected error occurred.");
      print("[DEBUG LIVE] Exception in startLiveRoom: $e\n$stack");
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> _initLiveEngine(String token, String appId, String channelId, int uid) async {
    final resolvedAppId = appId.isEmpty ? ApiConstants.agoraAppId : appId;
    print("[DEBUG LIVE] ================= INITIALIZE AGORA ENGINE =================");
    print("[DEBUG LIVE] App ID: $resolvedAppId");
    print("[DEBUG LIVE] Channel: $channelId");
    print("[DEBUG LIVE] UID: $uid");

    if (resolvedAppId.isEmpty) {
      Get.snackbar("Error", "Agora App ID is empty.");
      return;
    }

    // Release Flutter camera controller so Agora hardware layer can access camera
    if (cameraController != null) {
      print("[DEBUG LIVE] Disposing Flutter camera controller...");
      await cameraController!.dispose();
      cameraController = null;
      isCameraInitialized.value = false;
    }

    // Request permissions
    print("[DEBUG LIVE] Requesting Microphone and Camera permissions...");
    final perm = await [Permission.microphone, Permission.camera].request();
    print("[DEBUG LIVE] Permission results: Mic=${perm[Permission.microphone]}, Cam=${perm[Permission.camera]}");

    try {
      print("[DEBUG LIVE] Creating Agora RTC Engine...");
      liveEngine = createAgoraRtcEngine();
      
      print("[DEBUG LIVE] Initializing Agora RTC Engine context...");
      await liveEngine!.initialize(RtcEngineContext(
        appId: resolvedAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      // Register event handlers for live logging
      liveEngine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("[DEBUG LIVE] AGORA EVENT: Successfully joined channel: ${connection.channelId}, localUid: ${connection.localUid}, elapsed: $elapsed ms");
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("[DEBUG LIVE] AGORA EVENT: Remote viewer joined: $remoteUid");
            fetchLiveMemberCount();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print("[DEBUG LIVE] AGORA EVENT: Remote viewer left: $remoteUid (Reason: $reason)");
            fetchLiveMemberCount();
          },
          onError: (ErrorCodeType err, String msg) {
            print("[DEBUG LIVE] AGORA EVENT ERROR: $err - $msg");
          },
        ),
      );
      
      print("[DEBUG LIVE] Setting role to Broadcaster...");
      await liveEngine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      print("[DEBUG LIVE] Enabling video module...");
      await liveEngine!.enableVideo();
      
      print("[DEBUG LIVE] Starting local video preview...");
      await liveEngine!.startPreview();

      print("[DEBUG LIVE] Calling joinChannel (channelId: $channelId, uid: $uid)...");
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
      
      print("[DEBUG LIVE] joinChannel call succeeded!");
      isLiveEngineInitialized.value = true;
      liveDurationSeconds.value = 0;
      _liveDurationTimer?.cancel();
      _liveDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        liveDurationSeconds.value++;
      });
    } catch (e, stackTrace) {
      print("[DEBUG LIVE] Error initializing live engine: $e");
      print("[DEBUG LIVE] Stack trace: $stackTrace");
      Get.snackbar("Live Error", "Failed to initialize camera. Check App ID or permissions.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
      _cleanupAndNavigateToCamera();
    }
  }

  final isMicMuted = false.obs;

  bool minimizeToPip(BuildContext context) {
    if (liveEngine == null || !isLiveEngineInitialized.value) return true;
    
    print("[DEBUG LIVE] Minimizing to Picture-in-Picture mode");
    final pipService = Get.find<PipService>();
    pipService.showPip(
      context: context,
      engine: liveEngine!,
      onTap: restoreFromPip,
    );
    
    return true;
  }

  void restoreFromPip() {
    print("[DEBUG LIVE] Restoring from PiP mode to fullscreen");
    final pipService = Get.find<PipService>();
    pipService.hidePip();
    
    Get.toNamed('/create');
    navigateTo("LiveStream");
  }

  Future<void> toggleMic() async {
    isMicMuted.value = !isMicMuted.value;
    print("[DEBUG LIVE] Toggle Mic: isMuted=${isMicMuted.value}");
    if (liveEngine != null) {
      try {
        await liveEngine!.muteLocalAudioStream(isMicMuted.value);
        print("[DEBUG LIVE] muteLocalAudioStream called: ${isMicMuted.value}");
      } catch (e) {
        print("[DEBUG LIVE] Error muting audio: $e");
      }
    }
  }

  Future<void> switchCamera() async {
    isFrontCamera.value = !isFrontCamera.value;
    print("[DEBUG LIVE] Switching camera. isFront=${isFrontCamera.value}");
    if (liveEngine != null) {
      try {
        await liveEngine!.switchCamera();
        print("[DEBUG LIVE] Agora switchCamera completed successfully");
      } catch (e) {
        print("[DEBUG LIVE] Error switching camera: $e");
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

      print("[DEBUG LIVE] fetchLiveMemberCount [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List parsedList = [];
        int count = 0;
        if (data is Map) {
          if (data['results'] is List) {
            parsedList = data['results'];
            count = data['count'] ?? parsedList.length;
          } else if (data['members'] is List) {
            parsedList = data['members'];
            count = data['count'] ?? parsedList.length;
          } else if (data['data'] is List) {
            parsedList = data['data'];
            count = parsedList.length;
          } else {
            count = data['count'] ?? 0;
          }
        } else if (data is List) {
          parsedList = data;
          count = data.length;
        }
        liveMemberCount.value = count;
        liveMembers.value = parsedList;
        print("[DEBUG LIVE] Live members updated: count=$count, list=${parsedList.length}");
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception fetching member count: $e");
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

      print("[DEBUG LIVE] fetchLiveMessages [${response.statusCode}]: ${response.body}");

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
        print("[DEBUG LIVE] Live messages updated: total=${msgList.length}");
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception fetching messages: $e");
    }
  }

  Future<void> sendLiveMessage(String message) async {
    final text = message.trim();
    if (liveRoomId.value.isEmpty || text.isEmpty) return;
    print("[DEBUG LIVE] Sending live message: '$text' to room: ${liveRoomId.value}");
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
        body: jsonEncode({"message": text}),
      );

      print("[DEBUG LIVE] sendLiveMessage status: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Fetch messages immediately to show the new one dynamically
        await fetchLiveMessages();
      } else {
        print("[DEBUG LIVE] Failed to send message: ${response.statusCode}");
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception sending message: $e");
    }
  }

  Future<void> updateLiveRoom(Map<String, dynamic> data) async {
    if (liveRoomId.value.isEmpty) return;
    print("[DEBUG LIVE] Updating live room: ${liveRoomId.value} with data: $data");
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

      print("[DEBUG LIVE] updateLiveRoom response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        print("[DEBUG LIVE] Live room successfully updated!");
      } else {
        print("[DEBUG LIVE] Failed to update live room: ${response.statusCode}");
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception in updateLiveRoom: $e");
    }
  }

  Future<void> endLiveStream() async {
    final String currentRoomId = liveRoomId.value;
    print("[DEBUG LIVE] ================= END LIVE STREAM =================");
    print("[DEBUG LIVE] Ending room: $currentRoomId");
    Map<String, dynamic>? stats;
    
    // Stop engine and UI immediately so the user doesn't feel stuck
    if (liveEngine != null) {
      try {
        print("[DEBUG LIVE] Leaving Agora channel...");
        await liveEngine!.leaveChannel();
      } catch (e) {
        print("[DEBUG LIVE] Agora leaveChannel error: $e");
      }
      try {
        print("[DEBUG LIVE] Releasing Agora engine...");
        await liveEngine!.release();
      } catch (e) {
        print("[DEBUG LIVE] Agora release error: $e");
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
        print("[DEBUG LIVE] Calling end endpoint: $endUrl");
        
        final response = await apiClient.patch(
          endUrl,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}),
        );
        
        print("[DEBUG LIVE] End room response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Fetch stats dynamically
          try {
            final statsUrl = Uri.parse('${ApiConstants.baseUrl}live/rooms/$currentRoomId/stats/');
            print("[DEBUG LIVE] Fetching stream stats: $statsUrl");
            final statsResponse = await apiClient.get(
              statsUrl,
              headers: {if (token != null) 'Authorization': 'Bearer $token'},
            );
            print("[DEBUG LIVE] Stats response: ${statsResponse.statusCode} - ${statsResponse.body}");
            if (statsResponse.statusCode == 200) {
              stats = jsonDecode(statsResponse.body);
            }
          } catch (e) {
            print("[DEBUG LIVE] Exception fetching stats: $e");
          }
        }
      } catch (e) {
        print("[DEBUG LIVE] Exception in endLiveStream: $e");
      }
    }

    if (stats != null) {
      _showLiveStatsDialog(stats);
    }
  }

  void _showLiveStatsDialog(Map<String, dynamic> stats) {
    final durationSeconds = liveDurationSeconds.value;
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final totalViews = stats['total_views']?.toString() ??
        stats['views']?.toString() ??
        liveMemberCount.value.toString();
    final peakViewers = stats['peak_viewers']?.toString() ??
        stats['viewers']?.toString() ??
        liveMemberCount.value.toString();
    final totalMessages = stats['total_messages']?.toString() ??
        stats['messages_count']?.toString() ??
        liveMessages.length.toString();

    print("[DEBUG LIVE] Live stats dialog displayed: duration=$durationStr, views=$totalViews, peak=$peakViewers, messages=$totalMessages");

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
              _buildStatRow(Icons.timer_outlined, "Duration", durationStr),
              const SizedBox(height: 16),
              _buildStatRow(Icons.visibility, "Total Views", totalViews),
              const SizedBox(height: 16),
              _buildStatRow(Icons.group, "Peak Viewers", peakViewers),
              const SizedBox(height: 16),
              _buildStatRow(Icons.chat, "Total Messages", totalMessages),
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
    print("[DEBUG LIVE] Cleaning up live state and returning to Camera");
    liveTitle.value = "";
    liveTitleController.clear();
    liveRoomId.value = "";
    liveRoomData.value = null;
    liveMemberCount.value = 0;
    liveDurationSeconds.value = 0;
    liveMembers.clear();
    liveMessages.clear();
    _liveDurationTimer?.cancel();
    navigateTo("Camera");
    initCamera(); // Restore flutter camera
  }

  Future<void> deleteLiveRoom() async {
    final currentRoomId = liveRoomId.value;
    print("[DEBUG LIVE] deleteLiveRoom called for: $currentRoomId");
    if (currentRoomId.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$currentRoomId/');
      print("[DEBUG LIVE] Calling DELETE at: $url");
      
      final response = await apiClient.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("[DEBUG LIVE] DELETE response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 204 || response.statusCode == 200) {
        Get.snackbar("Deleted", "Live room was deleted successfully.", snackPosition: SnackPosition.BOTTOM);
      } else {
        print("[DEBUG LIVE] Failed to delete live room: ${response.statusCode}");
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception in deleteLiveRoom: $e");
    } finally {
      Get.find<PipService>().hidePip();
      if (liveEngine != null) {
        try {
          await liveEngine!.leaveChannel();
          await liveEngine!.release();
        } catch (e) {
          print("[DEBUG LIVE] Agora release error: $e");
        }
        liveEngine = null;
      }
      _memberPollTimer?.cancel();
      _messagePollTimer?.cancel();
      isLiveEngineInitialized.value = false;
      
      _cleanupAndNavigateToCamera();
    }
  }

  Future<void> inviteGuest(dynamic userId) async {
    if (liveRoomId.value.isEmpty || userId == null) return;
    print("[DEBUG LIVE] Inviting co-host user: $userId to room: ${liveRoomId.value}");
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/invite-cohost/');
      final response = await apiClient.post(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": userId}),
      );

      print("[DEBUG LIVE] inviteGuest response: ${response.statusCode} - ${response.body}");
      Get.snackbar("Invitation", "Invite sent to co-host!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
    } catch (e) {
      print("[DEBUG LIVE] Exception in inviteGuest: $e");
      Get.snackbar("Invitation", "Invite request sent!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
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
