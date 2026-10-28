import 'dart:async';
import 'dart:io';
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
import 'package:glotune/app/core/services/live_game_service.dart';
import 'package:video_player/video_player.dart' as vp;

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
  final remoteUids = <int>[].obs;
  final liveRoomId = "".obs;
  final liveRoomData = Rxn<Map<String, dynamic>>();
  final liveMemberCount = 0.obs;
  final liveMembers = <dynamic>[].obs;
  final invitedUserIds = <dynamic>{}.obs;
  final liveMessages = <dynamic>[].obs;
  final typingNotice = "".obs;
  Timer? _typingTimer;
  final temporaryNotice = "".obs;
  Timer? _temporaryNoticeTimer;

  void showTemporaryNotice(String message) {
    if (message.trim().isEmpty) return;
    temporaryNotice.value = message;
    _temporaryNoticeTimer?.cancel();
    _temporaryNoticeTimer = Timer(const Duration(seconds: 4), () {
      temporaryNotice.value = "";
    });
  }

  final isLoadingMembers = false.obs;
  final liveDurationSeconds = 0.obs;
  Timer? _messagePollTimer;
  Timer? _liveDurationTimer;
  WebSocket? _liveWs;

  // Stream for floating reactions for host screen
  final _reactionStreamController = StreamController<String>.broadcast();
  Stream<String> get reactionStream => _reactionStreamController.stream;
  final userProfile = Rxn<UserProfile>();
  final isGameModesVisible = false.obs;

  void toggleGameModes() {
    isGameModesVisible.value = !isGameModesVisible.value;
  }

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
    latencyMode.value = latencyMode.value == "Normal"
        ? "Low Latency"
        : "Normal";
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
  final selectedGameType = "".obs;
  final selectedLiveAction = "".obs;

  final gameOptionsList = [
    "Box battle",
    "1v1",
    "Quiz",
    "2v2 battle",
    "Karaoke",
  ];
  // Quiz Category & Live Quiz Game State
  final selectedQuizCategory = "Corporate and Business".obs;
  final quizCategoriesList = [
    "Entertainment and Pop Culture",
    "Corporate and Business",
    "Sport and Athletics",
    "Media and Journalism",
    "Politics and Governance",
  ];

  // Authoritative Live Quiz Game State
  final quizGameId = ''.obs;
  final quizGameStatus = 'WAITING_FOR_CATEGORY'.obs;
  final quizCategories = <Map<String, dynamic>>[
    {
      "id": "148d91e3-557a-4c76-a427-feebd079fb2c",
      "name": "Entertainment and Pop Culture",
      "description":
          "Music, cinema, television, celebrities, and global pop culture trivia.",
      "sort_order": 1,
      "status": "ACTIVE",
      "question_count": 5,
    },
    {
      "id": "8899e3a2-c59d-4eed-878f-871ad09bd980",
      "name": "Corporate and Business",
      "description":
          "Global markets, corporate giants, finance, entrepreneurship, and economics.",
      "sort_order": 2,
      "status": "ACTIVE",
      "question_count": 5,
    },
    {
      "id": "a624ddd4-1933-45ac-9a1e-868f4797128b",
      "name": "Sport and Athletics",
      "description":
          "Football, basketball, tennis, the Olympics, and legendary sports records.",
      "sort_order": 3,
      "status": "ACTIVE",
      "question_count": 5,
    },
    {
      "id": "edde6ae3-bf54-40d0-8320-5ee9329a4170",
      "name": "Media and Journalism",
      "description":
          "Broadcasting, news organizations, investigative reporting, ethics, and press history.",
      "sort_order": 4,
      "status": "ACTIVE",
      "question_count": 5,
    },
    {
      "id": "32337c06-51f3-4864-8169-2f476c9942c9",
      "name": "Politics and Governance",
      "description":
          "World governments, international relations, constitutions, and political history.",
      "sort_order": 5,
      "status": "ACTIVE",
      "question_count": 5,
    },
    {
      "id": "35aebcda-d98c-4347-978b-c789e44df0b5",
      "name": "Science and Technology",
      "description":
          "Physics, chemistry, astronomy, computer science, and modern technological innovations.",
      "sort_order": 6,
      "status": "ACTIVE",
      "question_count": 5,
    },
  ].obs;
  final isLoadingQuizCategories = false.obs;
  final selectedQuizCategoryId = '148d91e3-557a-4c76-a427-feebd079fb2c'.obs;
  final selectedQuizCategoryName = 'Entertainment and Pop Culture'.obs;

  // Active Round & Question State
  final activeQuizRoundId = ''.obs;
  final activeQuizRoundNo = 0.obs;
  final activeQuizQuestion = Rxn<Map<String, dynamic>>();
  final activeQuizAnswers = <Map<String, dynamic>>[].obs;
  final quizDeadlineAt = Rxn<DateTime>();
  final quizTimerSeconds = 30.obs;
  final quizTimerText = '00:30'.obs;
  final isQuizRoundActive = false.obs;
  final isQuizScored = false.obs;
  final selectedAnswerOption = ''.obs;
  final isAnswerSubmitted = false.obs;
  final correctAnswerOption = ''.obs;
  final firstCorrectUserId = Rxn<int>();

  // Participants & Rewards ($a + $b) from API
  final quizParticipants = <Map<String, dynamic>>[].obs;
  final quizRewards = <Map<String, dynamic>>[].obs;
  final totalFanGiftsEarned = 0.0.obs;
  final totalReleasedRewards = 0.0.obs;
  final hostShareEarnings = 0.0.obs;

  Timer? _quizRoundTimer;
  WebSocket? _quizWs;

  // ==================== LIVE KARAOKE GAME STATE ====================
  final karaokeGameId = ''.obs;
  final karaokeGameStatus = 'WAITING_FOR_SINGER'.obs;
  final karaokeActivePerformance = Rxn<Map<String, dynamic>>();
  final karaokePerformanceId = ''.obs;
  final karaokeCurrentSinger = ''.obs;
  final karaokeCurrentSingerId = 0.obs;
  final karaokeCurrentSingerSeat = '1'.obs;
  final karaokeCurrentTrackId = ''.obs;
  final karaokeCurrentTrackTitle = ''.obs;
  final karaokeCurrentTrackArtist = ''.obs;
  final karaokeCurrentTrackType =
      'INSTRUMENTAL'.obs; // 'MUSIC' or 'INSTRUMENTAL'
  final karaokeAudioUrl = ''.obs;
  final karaokePlaybackToken = ''.obs;
  final karaokeDurationMs = 0.obs;
  final karaokeIsRewardEligible = false.obs;
  final karaokeTimerSeconds = 0.obs;
  final karaokeTimerText = '00:00'.obs;
  final isKaraokePerformanceActive = false.obs;
  final karaokeCurrentLyricLine = 0.obs;
  final karaokeCurrentLyricText = ''.obs;
  final karaokeNextLyricText = ''.obs;
  final karaokeLyricsList = <Map<String, dynamic>>[].obs;
  final karaokeParticipants = <Map<String, dynamic>>[].obs;
  final karaokeCatalog = <Map<String, dynamic>>[].obs;
  final selectedKaraokeCategory = 'INSTRUMENTAL'.obs; // Default to INSTRUMENTAL
  final isKaraokeCatalogLoading = false.obs;
  final karaokeHeldReward = 0.0.obs;
  final karaokeTotalFanGifts = 0.0.obs;
  final karaokeTotalReleasedRewards = 0.0.obs;
  final karaokeTotalForfeitedRewards = 0.0.obs;
  final karaokeHostShareEarnings = 0.0.obs;

  Timer? _karaokeTimer;
  WebSocket? _karaokeWs;
  vp.VideoPlayerController? _karaokeAudioPlayer;

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

  // 1v1 Battle & Matchmaking State
  final activeMatchId = ''.obs;
  final activeLobbyId = ''.obs;
  final isMatchmaking = false.obs;
  final matchmakingDurationSeconds = 0.obs;
  Timer? _matchmakingTimer;
  Timer? _matchmakingHeartbeatTimer;
  Timer? _battleScorePollTimer;
  Timer? _battleCountdownTimer;

  final hostBattleScore = 3000.obs;
  final opponentBattleScore = 500.obs;
  final opponentName = 'Challenger 🥊'.obs;
  final opponentAvatar = ''.obs;
  final opponentUserId = Rxn<int>();
  final battleTimerSeconds = 180.obs;
  final battleTimerText = '03:00'.obs;
  final isBattleActive = false.obs;
  final isBattleEnded = false.obs;
  final battleWinner = ''.obs;

  // Live Background
  final selectedLiveBackground = (-1).obs;

  // Live Detailed Settings
  final guestCount = 3.obs;
  final timeLimit = "45 mins".obs;
  final showLayout = true.obs;
  final saveEveryday = true.obs;
  final isMuteViewers = false.obs;

  // Navigation within Create
  final currentStep = "Camera"
      .obs; // Camera, EditPost, UploadVideo, LiveStream, ModeratorManage, MuteViewers, FilterComments

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
    final user = member is Map && member['user'] is Map
        ? member['user']
        : (member is Map ? member : {});
    final userId = user['id'] ?? (member is Map ? member['id'] : null);
    final name =
        user['full_name'] ?? user['username'] ?? user['name'] ?? 'User';
    final handle = user['username'] != null ? '@${user['username']}' : '';
    final avatar = user['profile_picture'] ?? user['avatar'];

    print(
      "[DEBUG LIVE] toggleModerator: userId=$userId, name=$name, makeModerator=$makeModerator",
    );

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (liveRoomId.value.isNotEmpty && userId != null) {
        final url = Uri.parse(
          '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/moderators/',
        );
        if (makeModerator) {
          final res = await apiClient.post(
            url,
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'user_id': userId}),
          );
          print(
            "[DEBUG LIVE] Add moderator API [${res.statusCode}]: ${res.body}",
          );
        } else {
          final res = await apiClient.delete(
            Uri.parse(
              '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/moderators/$userId/',
            ),
            headers: {if (token != null) 'Authorization': 'Bearer $token'},
          );
          print(
            "[DEBUG LIVE] Remove moderator API [${res.statusCode}]: ${res.body}",
          );
        }
      }
    } catch (e) {
      print("[DEBUG LIVE] toggleModerator API error: $e");
    }

    if (makeModerator) {
      if (!moderators.any(
        (m) => (m['id'] != null && m['id'] == userId) || m['name'] == name,
      )) {
        moderators.add({
          'id': userId,
          'name': name,
          'handle': handle,
          'avatar': avatar,
          'role': 'Moderator',
        });
      }
      Get.snackbar(
        "Moderator",
        "$name is now a moderator",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } else {
      moderators.removeWhere(
        (m) => (m['id'] != null && m['id'] == userId) || m['name'] == name,
      );
      Get.snackbar(
        "Moderator",
        "$name removed from moderators",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
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
    if (isCameraInitialized.value || currentStep.value.startsWith("Live"))
      return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar(
          "Camera Not Found",
          "No cameras are available. Are you running on a simulator?",
          snackPosition: SnackPosition.BOTTOM,
        );
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
      print("Camera init error: $e");
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
        categoriesList.value = results
            .map((e) => CategoryModel.fromJson(e))
            .toList();
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

      var request = http.Request(
        'DELETE',
        Uri.parse('${ApiConstants.baseUrl}category/$id/'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.send(request);

      if (response.statusCode == 204 || response.statusCode == 200) {
        await fetchCategories();
        if (postCategory.value == id) {
          postCategory.value = categoriesList.isNotEmpty
              ? categoriesList.first.id
              : null;
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
    _stopKaraokeAudio();
    _karaokeTimer?.cancel();
    try {
      _karaokeWs?.close();
    } catch (_) {}
    liveTitleController.dispose();
    _recordingTimer?.cancel();
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
      final targetLens = isFrontCamera.value
          ? CameraLensDirection.front
          : CameraLensDirection.back;

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
    } else if (selectedTab.value == "Shorts")
      contentType = 'shorts';
    else if (selectedTab.value == "Live")
      contentType = 'live_stream';

    String titleToUse = contentType == 'post'
        ? postTitle.value
        : videoTitle.value;
    String descToUse = contentType == 'post'
        ? postCaption.value
        : videoDescription.value;

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
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, selectedMediaPath.value),
        );
      }

      // Attach explicitly selected thumbnail if uploading a video/shorts/live
      if (selectedThumbnailPath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'thumbnail',
            selectedThumbnailPath.value,
          ),
        );
      }

      print("========== API REQUEST ==========");
      print("URL: \$url");
      print("Headers: \${request.headers}");
      print("Fields: \${request.fields}");
      print(
        "Files: \${request.files.map((f) => '\${f.field}: \${f.filename}').toList()}",
      );
      print("=================================");

      final response = await apiClient.send(request);
      final respStr = await response.stream.bytesToString();

      print("========== API RESPONSE =========");
      print("Status Code: ${response.statusCode}");
      print("Body: $respStr");
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

    final enteredTitle =
        (liveTitleController.text.isNotEmpty
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
      print(
        "[DEBUG LIVE] Host Profile: ${userProfile.value?.fullName} (${userProfile.value?.email})",
      );

      final response = await apiClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"title": streamTitle}),
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

        print(
          "[DEBUG LIVE] Room created successfully! Room UUID: ${liveRoomId.value}",
        );

        // Start the stream on backend (supports PUT or PATCH /live/rooms/{room_id}/start/)
        try {
          final startUrl = Uri.parse(
            '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/start/',
          );
          print("[DEBUG LIVE] Calling start stream endpoint: $startUrl");
          final startRes = await apiClient.put(
            startUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({"status": "live"}),
          );
          print(
            "[DEBUG LIVE] PUT /start/ response: ${startRes.statusCode} - ${startRes.body}",
          );
          if (startRes.statusCode != 200 && startRes.statusCode != 204) {
            final patchRes = await apiClient.patch(
              startUrl,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({"status": "live"}),
            );
            print(
              "[DEBUG LIVE] PATCH /start/ response: ${patchRes.statusCode} - ${patchRes.body}",
            );
          }
        } catch (e) {
          print("[DEBUG LIVE] Start endpoint warning: $e");
        }

        // Extract Agora token and credentials from room response
        String? agoraToken =
            data['agora_token']?.toString() ?? data['token']?.toString();
        String? agoraAppId =
            data['agora_app_id']?.toString() ??
            data['app_id']?.toString() ??
            data['appId']?.toString();
        int uid =
            (data['host'] is int
                ? data['host'] as int
                : int.tryParse(data['host']?.toString() ?? '')) ??
            0;
        liveMemberCount.value =
            int.tryParse(
              data['viewer_count']?.toString() ??
                  data['member_count']?.toString() ??
                  '0',
            ) ??
            0;

        print(
          "[DEBUG LIVE] Initial Agora Token: ${agoraToken != null ? (agoraToken.length > 25 ? '${agoraToken.substring(0, 25)}...' : agoraToken) : 'none'}",
        );
        print("[DEBUG LIVE] Initial App ID: $agoraAppId, Host UID: $uid");

        // Fallback to fetch token if not in create room response
        if (agoraToken == null || agoraToken.isEmpty) {
          try {
            final tokenUrl = Uri.parse(
              '${ApiConstants.baseUrl}live/token/${liveRoomId.value}/',
            );
            print("[DEBUG LIVE] Fetching Agora token fallback from: $tokenUrl");
            final tokenResponse = await apiClient.get(
              tokenUrl,
              headers: {'Authorization': 'Bearer $token'},
            );
            print(
              "[DEBUG LIVE] Fallback Token response: ${tokenResponse.statusCode} - ${tokenResponse.body}",
            );
            if (tokenResponse.statusCode == 200) {
              final tokenData = jsonDecode(tokenResponse.body);
              agoraToken =
                  tokenData['agora_token']?.toString() ??
                  tokenData['token']?.toString();
              agoraAppId ??=
                  tokenData['agora_app_id']?.toString() ??
                  tokenData['app_id']?.toString() ??
                  tokenData['appId']?.toString();
              if (uid == 0) {
                uid =
                    (tokenData['agora_uid'] is int
                        ? tokenData['agora_uid'] as int
                        : int.tryParse(
                            tokenData['agora_uid']?.toString() ?? '',
                          )) ??
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
            print(
              "[DEBUG LIVE] Resolved Agora App ID from token prefix: $agoraAppId",
            );
          } else {
            agoraAppId = ApiConstants.agoraAppId;
            print(
              "[DEBUG LIVE] Resolved Agora App ID from ApiConstants: $agoraAppId",
            );
          }
        }

        Get.snackbar(
          "Success",
          "Live room created: ${liveTitle.value}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );

        // Navigate to the live stream view or selected game mode first to unmount CameraPreview
        if (selectedGameType.value == "Box battle") {
          navigateTo("LiveBoxBattle");
        } else if (selectedGameType.value == "1v1") {
          navigateTo("LiveBattle1v1");
        } else if (selectedGameType.value == "Quiz") {
          navigateTo("LiveQuiz");
        } else if (selectedGameType.value == "2v2 battle") {
          navigateTo("LiveBattle2v2");
        } else if (selectedGameType.value == "Karaoke") {
          navigateTo("LiveKaraoke");
        } else {
          navigateTo("LiveStream");
        }

        // Initialize Agora
        if (agoraToken != null &&
            agoraToken.isNotEmpty &&
            agoraAppId.isNotEmpty) {
          await _initLiveEngine(agoraToken, agoraAppId, liveRoomId.value, uid);
        } else {
          Get.snackbar("Error", "Could not get streaming credentials.");
          print("[DEBUG LIVE] Failed: Missing streaming credentials");
        }

        _messagePollTimer?.cancel();
        // Member count & events handled real-time via WebSocket
        _connectLiveWebSocket();

        if (selectedGameType.value == "Box battle") {
          startBoxBattle();
        }
      } else {
        Get.snackbar("Error", "Failed to start live: ${response.statusCode}");
        print(
          "[DEBUG LIVE] Error starting live room: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e, stack) {
      Get.snackbar("Error", "An unexpected error occurred.");
      print("[DEBUG LIVE] Exception in startLiveRoom: $e\n$stack");
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> _initLiveEngine(
    String token,
    String appId,
    String channelId,
    int uid,
  ) async {
    final resolvedAppId = appId.isEmpty ? ApiConstants.agoraAppId : appId;
    print(
      "[DEBUG LIVE] ================= INITIALIZE AGORA ENGINE =================",
    );
    print("[DEBUG LIVE] App ID: $resolvedAppId");
    print("[DEBUG LIVE] Channel: $channelId");
    print("[DEBUG LIVE] UID: $uid");

    if (resolvedAppId.isEmpty) {
      Get.snackbar("Error", "Agora App ID is empty.");
      return;
    }

    // Release Flutter camera controller so Agora hardware layer can access camera exclusively
    if (cameraController != null) {
      print("[DEBUG LIVE] Disposing Flutter camera controller...");
      try {
        await cameraController!.dispose();
      } catch (_) {}
      cameraController = null;
      isCameraInitialized.value = false;
      // Allow Android camera device manager time to finish closing CameraId-1
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Request permissions
    print("[DEBUG LIVE] Requesting Microphone and Camera permissions...");
    final perm = await [Permission.microphone, Permission.camera].request();
    print(
      "[DEBUG LIVE] Permission results: Mic=${perm[Permission.microphone]}, Cam=${perm[Permission.camera]}",
    );

    try {
      print("[DEBUG LIVE] Creating Agora RTC Engine...");
      liveEngine = createAgoraRtcEngine();

      print("[DEBUG LIVE] Initializing Agora RTC Engine context...");
      await liveEngine!.initialize(
        RtcEngineContext(
          appId: resolvedAppId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      // Register event handlers for live logging
      liveEngine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print(
              "[DEBUG LIVE] AGORA EVENT: Successfully joined channel: ${connection.channelId}, localUid: ${connection.localUid}, elapsed: $elapsed ms",
            );
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print(
              "[DEBUG LIVE] AGORA EVENT: Remote co-host joined: $remoteUid",
            );
            if (!remoteUids.contains(remoteUid)) {
              remoteUids.add(remoteUid);
            }
            if (isBoxBattleActive.value) {
              assignGuestToVacantSlot(remoteUid);
            }
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                print(
                  "[DEBUG LIVE] AGORA EVENT: Remote co-host left: $remoteUid (Reason: $reason)",
                );
                remoteUids.remove(remoteUid);
                if (isBoxBattleActive.value) {
                  _freeSlotByUid(remoteUid);
                }
              },
          onError: (ErrorCodeType err, String msg) {
            print("[DEBUG LIVE] AGORA EVENT ERROR: $err - $msg");
          },
        ),
      );

      print("[DEBUG LIVE] Setting role to Broadcaster...");
      await liveEngine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );

      print("[DEBUG LIVE] Enabling video module...");
      await liveEngine!.enableVideo();

      print("[DEBUG LIVE] Starting local video preview...");
      await liveEngine!.startPreview();

      print(
        "[DEBUG LIVE] Calling joinChannel (channelId: $channelId, uid: $uid)...",
      );
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
      Get.snackbar(
        "Live Error",
        "Failed to initialize camera. Check App ID or permissions.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
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

  Future<void> fetchLiveParticipants() async {
    if (liveRoomId.value.isEmpty) return;
    try {
      isLoadingMembers.value = true;
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final url = Uri.parse(
        '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/members/',
      );
      final response = await apiClient.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      print(
        "[DEBUG LIVE] fetchLiveParticipants [${response.statusCode}]: ${response.body}",
      );

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
        print(
          "[DEBUG LIVE] Live members updated: count=$count, list=${parsedList.length}",
        );
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception fetching members: $e");
    } finally {
      isLoadingMembers.value = false;
    }
  }

  Future<void> fetchLiveMessages() async {
    if (liveRoomId.value.isEmpty) return;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final url = Uri.parse(
        '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/messages/',
      );
      final response = await apiClient.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      print(
        "[DEBUG LIVE] fetchLiveMessages [${response.statusCode}]: ${response.body}",
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
        print("[DEBUG LIVE] Live messages updated: total=${msgList.length}");
      }
    } catch (e) {
      print("[DEBUG LIVE] Exception fetching messages: $e");
    }
  }

  Future<void> sendLiveMessage(String message) async {
    final text = message.trim();
    if (liveRoomId.value.isEmpty || text.isEmpty) return;
    print(
      "[DEBUG LIVE] Sending live message via socket: '$text' to room: ${liveRoomId.value}",
    );

    try {
      if (_liveWs != null) {
        final payload = jsonEncode({"action": "message", "message": text});
        _liveWs!.add(payload);
        print("[DEBUG LIVE WS] Message sent: $payload");
      } else {
        print(
          "[DEBUG LIVE WS] WebSocket not connected; attempting reconnect...",
        );
        _connectLiveWebSocket();
      }
    } catch (e) {
      print("[DEBUG LIVE WS] Error sending message: $e");
    }
  }

  void sendSocketTyping(bool isTyping) {
    try {
      if (_liveWs != null) {
        _liveWs!.add(jsonEncode({"action": "typing", "is_typing": isTyping}));
      }
    } catch (e) {
      print("[DEBUG LIVE WS] Error sending typing status: $e");
    }
  }

  Future<void> updateLiveRoom(Map<String, dynamic> data) async {
    if (liveRoomId.value.isEmpty) return;
    print(
      "[DEBUG LIVE] Updating live room: ${liveRoomId.value} with data: $data",
    );
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final url = Uri.parse(
        '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/',
      );

      final response = await apiClient.patch(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print(
        "[DEBUG LIVE] updateLiveRoom response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        print("[DEBUG LIVE] Live room successfully updated!");
      } else {
        print(
          "[DEBUG LIVE] Failed to update live room: ${response.statusCode}",
        );
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
    _messagePollTimer?.cancel();
    isLiveEngineInitialized.value = false;

    // Clean up and route back to camera
    _cleanupAndNavigateToCamera();

    if (currentRoomId.isNotEmpty) {
      try {
        final authService = Get.find<AuthService>();
        final token = authService.accessToken.value;
        final endUrl = Uri.parse(
          '${ApiConstants.baseUrl}live/rooms/$currentRoomId/end/',
        );
        print("[DEBUG LIVE] Calling end endpoint: $endUrl");

        final response = await apiClient.patch(
          endUrl,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}),
        );

        print(
          "[DEBUG LIVE] End room response: ${response.statusCode} - ${response.body}",
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Fetch stats dynamically
          try {
            final statsUrl = Uri.parse(
              '${ApiConstants.baseUrl}live/rooms/$currentRoomId/stats/',
            );
            print("[DEBUG LIVE] Fetching stream stats: $statsUrl");
            final statsResponse = await apiClient.get(
              statsUrl,
              headers: {if (token != null) 'Authorization': 'Bearer $token'},
            );
            print(
              "[DEBUG LIVE] Stats response: ${statsResponse.statusCode} - ${statsResponse.body}",
            );
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
    final durationStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final totalViews =
        stats['total_views']?.toString() ??
        stats['views']?.toString() ??
        liveMemberCount.value.toString();
    final peakViewers =
        stats['peak_viewers']?.toString() ??
        stats['viewers']?.toString() ??
        liveMemberCount.value.toString();
    final totalMessages =
        stats['total_messages']?.toString() ??
        stats['messages_count']?.toString() ??
        liveMessages.length.toString();

    print(
      "[DEBUG LIVE] Live stats dialog displayed: duration=$durationStr, views=$totalViews, peak=$peakViewers, messages=$totalMessages",
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Live Stream Ended",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Get.back(); // close dialog
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    invitedUserIds.clear();
    remoteUids.clear();
    liveMessages.clear();
    _liveDurationTimer?.cancel();
    _typingTimer?.cancel();
    _temporaryNoticeTimer?.cancel();
    temporaryNotice.value = "";
    selectedGameType.value = "";
    showGameOptions.value = false;
    _quizRoundTimer?.cancel();
    try {
      _quizWs?.close();
    } catch (_) {}
    _quizWs = null;
    quizGameId.value = "";
    quizGameStatus.value = "WAITING_FOR_CATEGORY";
    isQuizRoundActive.value = false;
    activeQuizRoundId.value = "";
    activeQuizRoundNo.value = 0;
    activeQuizQuestion.value = null;
    activeQuizAnswers.clear();
    quizParticipants.clear();
    selectedAnswerOption.value = "";
    isAnswerSubmitted.value = false;
    isQuizScored.value = false;
    correctAnswerOption.value = "";
    firstCorrectUserId.value = null;
    selectedQuizCategoryId.value = "";
    selectedQuizCategoryName.value = "";
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

      final url = Uri.parse(
        '${ApiConstants.baseUrl}live/rooms/$currentRoomId/',
      );
      print("[DEBUG LIVE] Calling DELETE at: $url");

      final response = await apiClient.delete(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      print(
        "[DEBUG LIVE] DELETE response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        Get.snackbar(
          "Deleted",
          "Live room was deleted successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print(
          "[DEBUG LIVE] Failed to delete live room: ${response.statusCode}",
        );
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
      _messagePollTimer?.cancel();
      try {
        _liveWs?.close();
        _liveWs = null;
      } catch (_) {}
      isLiveEngineInitialized.value = false;

      _cleanupAndNavigateToCamera();
    }
  }

  String? _pendingSessionJoin;
  String? _currentJoinedSession;
  DateTime? _lastJoinSessionTime;
  bool _isConnectingLiveWs = false;

  /// Send session join event to WebSocket:
  /// e.g. {"action": "join", "type": "box battle"}
  void joinSession(String sessionType) {
    String normalized = sessionType.toLowerCase().trim();
    if (normalized == 'box' || normalized.contains('box battle')) {
      normalized = 'box battle';
    } else if (normalized.contains('1v1')) {
      normalized = '1v1';
    } else if (normalized.contains('2v2')) {
      normalized = '2v2';
    } else if (normalized.contains('quiz')) {
      normalized = 'quiz';
    } else if (normalized.contains('karaoke')) {
      normalized = 'karaoke';
    } else {
      normalized = 'live';
    }

    final now = DateTime.now();
    // Guard: Prevent sending duplicate join if already in this session
    if (_currentJoinedSession == normalized &&
        _lastJoinSessionTime != null &&
        now.difference(_lastJoinSessionTime!).inSeconds < 5) {
      print("[DEBUG LIVE WS] Suppressing duplicate join for '$normalized'");
      return;
    }

    _currentJoinedSession = normalized;
    _lastJoinSessionTime = now;

    final payload = jsonEncode({"action": "join", "type": normalized});

    final changeTypePayload = jsonEncode({
      "action": "change_live_type",
      "type": "change_live_type",
      "live_type": normalized,
      "game_type": normalized,
      "room_id": liveRoomId.value,
    });

    if (_liveWs != null) {
      try {
        _liveWs!.add(payload);
        _liveWs!.add(changeTypePayload);
        print(
          "[DEBUG LIVE WS] Sent join session: $payload & change type: $changeTypePayload",
        );
      } catch (e) {
        print("[DEBUG LIVE WS] Error sending join session: $e");
      }
    } else {
      print(
        "[DEBUG LIVE WS] Socket not yet connected, queuing join session: $normalized",
      );
      _pendingSessionJoin = normalized;
      if (liveRoomId.value.isNotEmpty) {
        _connectLiveWebSocket();
      }
    }
  }

  void _connectLiveWebSocket() {
    if (liveRoomId.value.isEmpty) return;
    if (_liveWs != null || _isConnectingLiveWs) {
      print("[DEBUG LIVE WS] Already connected or connection in progress");
      return;
    }

    _isConnectingLiveWs = true;

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';
      final primaryWsUrl =
          '$wsScheme://${parsed.host}$portStr/api/ws/live/${liveRoomId.value}/?token=${token ?? ''}';
      final fallbackWsUrl =
          '$wsScheme://${parsed.host}$portStr/ws/live/${liveRoomId.value}/?token=${token ?? ''}';

      void listenWs(WebSocket ws) {
        _isConnectingLiveWs = false;
        if (_liveWs != null && _liveWs != ws) {
          try {
            _liveWs!.close();
          } catch (_) {}
        }
        _liveWs = ws;
        print(
          "[DEBUG LIVE WS] Host connected successfully to: ${ws.toString()}",
        );

        // Send queued or default session join ONLY ONCE
        final joinType =
            _pendingSessionJoin ??
            (isBoxBattleActive.value ? "box battle" : "live");
        _pendingSessionJoin = null;
        _currentJoinedSession = joinType;
        _lastJoinSessionTime = DateTime.now();

        final joinPayload = jsonEncode({"action": "join", "type": joinType});
        final changeTypePayload = jsonEncode({
          "action": "change_live_type",
          "type": "change_live_type",
          "live_type": joinType,
          "game_type": joinType,
          "room_id": liveRoomId.value,
        });

        try {
          ws.add(joinPayload);
          ws.add(changeTypePayload);
          print("[DEBUG LIVE WS] Sent join on connect: $joinPayload");
        } catch (e) {
          print("[DEBUG LIVE WS] Error sending join on connect: $e");
        }

        ws.listen(
          (event) {
            try {
              final data = jsonDecode(event.toString());
              print("[DEBUG LIVE WS Event]: $data");
              if (data is Map<String, dynamic>) {
                _handleHostWebSocketEvent(data);
              }
            } catch (e) {
              print("[DEBUG LIVE WS] Error parsing event: $e");
            }
          },
          onError: (err) {
            print("[DEBUG LIVE WS] Stream error: $err");
            _liveWs = null;
            _isConnectingLiveWs = false;
          },
          onDone: () {
            print("[DEBUG LIVE WS] Stream closed");
            _liveWs = null;
            _isConnectingLiveWs = false;
          },
        );
      }

      print("[DEBUG LIVE WS] Host connecting to primary: $primaryWsUrl");
      WebSocket.connect(primaryWsUrl)
          .then((ws) {
            listenWs(ws);
          })
          .catchError((err) {
            print(
              "[DEBUG LIVE WS] Primary connect error ($err), attempting fallback to: $fallbackWsUrl",
            );
            WebSocket.connect(fallbackWsUrl)
                .then((ws) {
                  listenWs(ws);
                })
                .catchError((fallbackErr) {
                  _isConnectingLiveWs = false;
                  print("[DEBUG LIVE WS] Fallback connect error: $fallbackErr");
                });
          });
    } catch (e) {
      _isConnectingLiveWs = false;
      print("[DEBUG LIVE WS] Connect exception: $e");
    }
  }

  void _handleHostWebSocketEvent(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final action = data['action']?.toString();

    // 1. New chat message
    if (type == 'message' || action == 'message') {
      final text = (data['message'] ?? data['text'] ?? data['content'])
          ?.toString();
      if (text != null && text.trim().isNotEmpty) {
        final msgId = data['message_id'] ?? data['id'];
        final username = data['username'] ?? data['user']?['username'];
        final time = data['timestamp'] ?? data['created_at'];

        // Normalize message object
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
            if (msgId != null &&
                mId != null &&
                msgId.toString() == mId.toString()) {
              return true;
            }
            final mText = (m['message'] ?? m['text'] ?? m['content'])
                ?.toString();
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
            liveMessages[existingIndex] = {...existing, ...normalized};
          }
        } else {
          liveMessages.insert(0, normalized);
          print("[DEBUG LIVE WS] Inserted message: $normalized");
        }
      }
    }
    // 2. Incoming like, heart or reaction from viewer
    else if (type == 'like' ||
        action == 'like' ||
        type == 'heart' ||
        action == 'heart' ||
        type == 'love' ||
        action == 'love' ||
        type == 'reaction' ||
        action == 'reaction') {
      final reactionName =
          (type == 'heart' ||
              action == 'heart' ||
              type == 'love' ||
              action == 'love')
          ? 'heart'
          : (data['reaction_type']?.toString() ??
                data['reaction']?.toString() ??
                'like');
      print("[DEBUG LIVE WS] Incoming reaction event: $reactionName");
      _reactionStreamController.add(reactionName);
    }
    // 3. Incoming gift (gift_received room broadcast)
    else if (type == 'gift_received' ||
        data['event']?.toString() == 'gift_received' ||
        action == 'gift_received' ||
        type == 'gift') {
      final dynamic rawData = data['data'];
      final Map<String, dynamic> giftData = (rawData is Map<String, dynamic>)
          ? rawData
          : data;
      final giftCode = giftData['gift_code']?.toString() ?? '';
      final giftName = giftData['gift_name']?.toString() ??
          giftData['gift_type']?.toString() ??
          'Gift';
      final quantity = giftData['quantity'] ?? 1;
      final coins = giftData['coins'] ?? 0;
      final totalCoins = giftData['total_coins'] ?? (coins * quantity);
      final senderName = giftData['sender_name']?.toString() ??
          data['username'] ??
          data['user']?['username'] ??
          'Someone';
      final recipientName = giftData['recipient_name']?.toString() ?? '';
      final giftIdentifier = giftCode.isNotEmpty ? giftCode : giftName;

      print("[DEBUG LIVE WS] Host received gift broadcast: $giftIdentifier x$quantity from $senderName");
      _reactionStreamController.add(giftIdentifier);

      final toStr = recipientName.isNotEmpty ? ' to $recipientName' : '';
      final coinStr = totalCoins > 0 ? ' ($totalCoins coins)' : '';
      liveMessages.insert(0, {
        'message': '🎁 $senderName sent $quantity $giftName$coinStr$toStr!',
        'user': {'username': 'System'},
        'is_system': true,
        'gift_code': giftCode,
        'gift_name': giftName,
        'quantity': quantity,
        'total_coins': totalCoins,
        'sender_name': senderName,
        'recipient_name': recipientName,
      });
    }
    // 4. Viewer typing
    else if (type == 'typing') {
      final isTyping = data['is_typing'] == true || data['is_typing'] == 'true';
      final username =
          data['username'] ?? data['user']?['username'] ?? 'Someone';
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
    // 5. Member count / action updates
    else if (type == 'member_action') {
      final countVal =
          data['viewer_count'] ?? data['member_count'] ?? data['count'];
      if (countVal != null) {
        final parsed = int.tryParse(countVal.toString());
        if (parsed != null) {
          liveMemberCount.value = parsed;
          print("[DEBUG LIVE WS] Updated liveMemberCount to: $parsed");
        }
      }

      final username = data['username'] ?? data['user']?['username'] ?? '';
      String noticeMsg =
          (data['message'] ?? data['text'] ?? '')?.toString().trim() ?? '';
      if (noticeMsg.isEmpty && action != null) {
        if (action == 'user_left') {
          noticeMsg = username.isNotEmpty
              ? '@$username left the LIVE'
              : 'A viewer left the LIVE';
        } else if (action == 'user_joined') {
          noticeMsg = username.isNotEmpty
              ? '@$username joined the LIVE'
              : 'A new viewer joined the LIVE';
        }
      }

      // Update real liveMembers list from socket
      if (action == 'user_joined') {
        final userId = data['user_id'] ?? data['id'] ?? data['user']?['id'];
        final pic =
            data['profile_picture'] ??
            data['avatar'] ??
            data['user']?['profile_picture'] ??
            data['user']?['avatar'];
        final memberObj = {
          'id': userId,
          'user_id': userId,
          'username': username,
          'profile_picture': pic,
          'user': {'id': userId, 'username': username, 'profile_picture': pic},
        };
        final existsIndex = liveMembers.indexWhere((m) {
          final mId = (m is Map
              ? (m['user']?['id'] ?? m['id'] ?? m['user_id'])
              : null);
          return mId != null &&
              userId != null &&
              mId.toString() == userId.toString();
        });
        if (existsIndex != -1) {
          liveMembers[existsIndex] = memberObj;
        } else {
          liveMembers.insert(0, memberObj);
        }
      } else if (action == 'user_left') {
        final userId = data['user_id'] ?? data['id'] ?? data['user']?['id'];
        if (userId != null) {
          liveMembers.removeWhere((m) {
            final mId = (m is Map
                ? (m['user']?['id'] ?? m['id'] ?? m['user_id'])
                : null);
            return mId != null && mId.toString() == userId.toString();
          });
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
    // 6. Join or stream requests from viewers
    else if (type == 'stream_request' && data['action'] == 'requested') {
      final requesterName =
          data['requester_username'] ?? data['username'] ?? 'User';
      final requesterId = data['requester_id'] ?? data['user_id'];
      Get.snackbar(
        'Stream Request',
        '$requesterName wants to join your stream as a guest!',
        backgroundColor: Colors.indigoAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            if (requesterId != null) {
              inviteGuest(requesterId);
            }
          },
          child: const Text(
            'Accept',
            style: TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    // 7. Box Battle events (PDF Section 14)
    else if (type == 'guest_gift_update' || action == 'guest_gift_update') {
      final slotNumber = data['slot_number'];
      final giftTotal = data['gift_total'];
      final bonusTotal = data['bonus_total'];
      if (slotNumber != null) {
        final slotNum = int.tryParse(slotNumber.toString());
        final idx = boxSlots.indexWhere((s) => s['slot_number'] == slotNum);
        if (idx != -1) {
          final s = Map<String, dynamic>.from(boxSlots[idx]);
          if (giftTotal != null) s['gift_total'] = giftTotal;
          if (bonusTotal != null) s['bonus_total'] = bonusTotal;
          boxSlots[idx] = s;
        }
      }
    } else if (type == 'box_slot_update' ||
        action == 'box_slot_update' ||
        type == 'box_slot_join' ||
        type == 'box_slot_leave') {
      final slotNumber = data['slot_number'];
      final status =
          data['status']?.toString() ??
          (type == 'box_slot_leave' ? 'VACANT' : 'OCCUPIED');
      if (slotNumber != null) {
        final slotNum = int.tryParse(slotNumber.toString());
        if (slotNum != null) {
          final idx = boxSlots.indexWhere((s) => s['slot_number'] == slotNum);
          if (idx != -1) {
            if (status == 'VACANT') {
              boxSlots[idx] = {
                'slot_number': slotNum,
                'status': 'VACANT',
                'uid': null,
                'guest_id': null,
                'username': '',
                'gift_total': 0,
                'bonus_total': 0,
                'mic_on': true,
                'camera_on': true,
              };
            } else {
              final s = Map<String, dynamic>.from(boxSlots[idx]);
              s['status'] = 'OCCUPIED';
              s['uid'] = data['uid'] ?? data['user_id'];
              s['guest_id'] = data['user_id'];
              s['username'] = data['username'] ?? 'Guest $slotNum';
              if (data['profile_picture'] != null) {
                s['profile_picture'] = data['profile_picture'];
              }
              boxSlots[idx] = s;
            }
          }
        }
      }
    } else if (type == 'battle_ended' || action == 'battle_ended') {
      endBoxBattle();
    }
    // 8. Session status & join notifications
    else if (type == 'session_status' ||
        type == 'session_status_notification') {
      _handleSessionStatusEvent(data);
    }
  }

  void _handleSessionStatusEvent(Map<String, dynamic> data) {
    print("[DEBUG LIVE WS] Handling session status event: $data");
    final type = data['type']?.toString();
    final status = data['status']?.toString() ?? 'join';
    final gameType = data['game_type']?.toString() ?? 'session';
    final username = data['username']?.toString() ?? 'User';
    final userId = data['user_id'];
    final profilePic = data['profile_picture']?.toString();
    final rawMsg = data['message']?.toString();
    final displayMsg = (rawMsg != null && rawMsg.trim().isNotEmpty)
        ? (rawMsg.startsWith('@') ? rawMsg : '@$username $rawMsg')
        : '@$username joined $gameType';
    final time =
        data['timestamp']?.toString() ?? DateTime.now().toIso8601String();

    // Resolve full image URL if relative path
    String? resolvedPic = profilePic;
    if (resolvedPic != null &&
        resolvedPic.isNotEmpty &&
        !resolvedPic.startsWith('http')) {
      final origin = Uri.parse(ApiConstants.baseUrl).origin;
      resolvedPic =
          '$origin${resolvedPic.startsWith('/') ? '' : '/'}$resolvedPic';
    }

    // 1. Insert into liveMessages for chat feed
    final chatItem = {
      'id': 'sess_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      'message': displayMsg,
      'text': displayMsg,
      'username': username,
      'user_id': userId,
      'profile_picture': resolvedPic,
      'timestamp': time,
      'is_system': true,
      'is_session_notification': true,
      'game_type': gameType,
      'status': status,
      'type': type,
    };
    liveMessages.insert(0, chatItem);

    // 2. Show floating temporary notice / banner
    showTemporaryNotice(displayMsg);

    // 3. Update Participant Part:
    // 3a. Add to liveMembers list
    final memberObj = {
      'id': userId,
      'user_id': userId,
      'username': username,
      'profile_picture': resolvedPic,
      'game_type': gameType,
      'user': {
        'id': userId,
        'username': username,
        'profile_picture': resolvedPic,
      },
    };
    final memberIdx = liveMembers.indexWhere((m) {
      final mId = (m is Map
          ? (m['user']?['id'] ?? m['id'] ?? m['user_id'])
          : null);
      return mId != null &&
          userId != null &&
          mId.toString() == userId.toString();
    });
    if (memberIdx != -1) {
      liveMembers[memberIdx] = memberObj;
    } else {
      liveMembers.insert(0, memberObj);
      liveMemberCount.value = liveMembers.length;
    }

    // 3b. Update Box Battle guest slots if game_type is "box battle"
    final normalizedGameType = gameType.toLowerCase().trim();
    if (normalizedGameType.contains('box')) {
      final existingSlotIdx = boxSlots.indexWhere((s) {
        final sUid = s['user_id'] ?? s['guest_id'] ?? s['uid'];
        return sUid != null &&
            userId != null &&
            sUid.toString() == userId.toString();
      });
      if (existingSlotIdx == -1) {
        final vacantIdx = boxSlots.indexWhere((s) => s['status'] == 'VACANT');
        if (vacantIdx != -1) {
          final updated = Map<String, dynamic>.from(boxSlots[vacantIdx]);
          updated['status'] = 'OCCUPIED';
          updated['user_id'] = userId;
          updated['guest_id'] = userId;
          updated['uid'] = userId is int
              ? userId
              : int.tryParse(userId.toString());
          updated['username'] = username;
          updated['profile_picture'] = resolvedPic;
          updated['gift_total'] = 0;
          updated['bonus_total'] = 0;
          updated['mic_on'] = true;
          updated['camera_on'] = true;
          boxSlots[vacantIdx] = updated;
        }
      }
    }

    // 3c. Update Quiz participants if game_type is "quiz"
    if (normalizedGameType.contains('quiz')) {
      final existsInQuiz = quizParticipants.any((p) {
        final pId = p['user_id'] ?? p['id'];
        return pId != null &&
            userId != null &&
            pId.toString() == userId.toString();
      });
      if (!existsInQuiz && userId != null) {
        quizParticipants.add({
          'user_id': userId,
          'username': username,
          'profile_picture': resolvedPic,
          'fan_gifts_a': 0,
          'platform_reward_b': 0,
          'selected_option': null,
          'is_correct': false,
        });
      }
    }
  }

  Future<void> inviteGuest(dynamic userId) async {
    if (liveRoomId.value.isEmpty || userId == null) return;
    final parsedUserId = int.tryParse(userId.toString()) ?? userId;
    print(
      "[DEBUG LIVE] Inviting participant user: $parsedUserId to room: ${liveRoomId.value}",
    );

    // Track invited state immediately for responsive UI
    invitedUserIds.add(userId);
    invitedUserIds.add(userId.toString());
    invitedUserIds.add(parsedUserId);

    // 1. Send immediate real-time invitation over WebSocket so guest receives it instantly
    try {
      if (_liveWs == null) {
        _connectLiveWebSocket();
      }
      if (_liveWs != null) {
        final hostName = liveRoomData.value?['host']?['username'] ?? "Host";
        final inviteWsPayload = jsonEncode({
          "type": "cohost_invite",
          "action": "invite",
          "target_user_id": parsedUserId,
          "invited_user_id": parsedUserId,
          "user_id": parsedUserId,
          "user_ids": [parsedUserId],
          "username": hostName,
          "host_username": hostName,
          "room_id": liveRoomId.value,
        });
        _liveWs!.add(inviteWsPayload);
        print(
          "[DEBUG LIVE WS] Sent cohost_invite via WebSocket: $inviteWsPayload",
        );
      }
    } catch (wsErr) {
      print("[DEBUG LIVE WS] Error sending invite via WS: $wsErr");
    }

    // 2. Also notify backend API (primary: /api/live/rooms/{roomId}/invite/)
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final endpoints = [
        '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/invite/',
        '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/invite-cohost/',
      ];

      for (final ep in endpoints) {
        try {
          final res = await apiClient.post(
            Uri.parse(ep),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "user_ids": [parsedUserId],
              "role": "viewer",
              "user_id": parsedUserId,
            }),
          );
          print(
            "[DEBUG LIVE] inviteGuest at $ep response: ${res.statusCode} - ${res.body}",
          );
          if (res.statusCode == 200 || res.statusCode == 201) {
            break;
          }
        } catch (_) {}
      }

      Get.snackbar(
        "Invitation Sent",
        "Participant invitation sent successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      print("[DEBUG LIVE] Exception in inviteGuest: $e");
      Get.snackbar(
        "Invitation Sent",
        "Participant invitation sent!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  // ================= BOX BATTLE (PDF SPECIFICATION) =================
  final isBoxBattleActive = false.obs;
  final boxBattleTimerSeconds = 90.obs;
  Timer? _boxBattleTimer;
  final boxSlots = <Map<String, dynamic>>[].obs;

  String get formattedBoxBattleTimer {
    final s = boxBattleTimerSeconds.value;
    final m = s ~/ 60;
    final rem = s % 60;
    return "$m:${rem.toString().padLeft(2, '0')}";
  }

  void initBoxBattleSlots() {
    final List<Map<String, dynamic>> slots = [];
    final currentGuests = List<int>.from(remoteUids);

    for (int i = 1; i <= 8; i++) {
      if (i - 1 < currentGuests.length) {
        final uid = currentGuests[i - 1];
        slots.add({
          'slot_number': i,
          'status': 'OCCUPIED',
          'uid': uid,
          'guest_id': uid,
          'username': 'Guest $i',
          'gift_total': 200,
          'bonus_total': 30,
          'mic_on': true,
          'camera_on': true,
        });
      } else {
        slots.add({
          'slot_number': i,
          'status': 'VACANT',
          'uid': null,
          'guest_id': null,
          'username': '',
          'gift_total': 0,
          'bonus_total': 0,
          'mic_on': true,
          'camera_on': true,
        });
      }
    }
    boxSlots.value = slots;
  }

  void assignGuestToVacantSlot(int uid, {String? username}) {
    final vacantIndex = boxSlots.indexWhere((s) => s['status'] == 'VACANT');
    if (vacantIndex != -1) {
      final slotNum = boxSlots[vacantIndex]['slot_number'];
      final updated = Map<String, dynamic>.from(boxSlots[vacantIndex]);
      updated['status'] = 'OCCUPIED';
      updated['uid'] = uid;
      updated['guest_id'] = uid;
      updated['username'] = username ?? 'Guest $slotNum';
      updated['gift_total'] = 200;
      updated['bonus_total'] = 30;
      updated['mic_on'] = true;
      updated['camera_on'] = true;
      boxSlots[vacantIndex] = updated;
    }
  }

  void _freeSlotByUid(int uid) {
    final index = boxSlots.indexWhere((s) => s['uid'] == uid);
    if (index != -1) {
      final slotNum = boxSlots[index]['slot_number'];
      boxSlots[index] = {
        'slot_number': slotNum,
        'status': 'VACANT',
        'uid': null,
        'guest_id': null,
        'username': '',
        'gift_total': 0,
        'bonus_total': 0,
        'mic_on': true,
        'camera_on': true,
      };
    }
  }

  Future<void> startBoxBattle() async {
    isBoxBattleActive.value = true;
    initBoxBattleSlots();
    boxBattleTimerSeconds.value = 90;
    _boxBattleTimer?.cancel();
    _boxBattleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (boxBattleTimerSeconds.value > 0) {
        boxBattleTimerSeconds.value--;
      } else {
        timer.cancel();
      }
    });

    try {
      if (_liveWs != null) {
        _liveWs!.add(
          jsonEncode({
            "type": "battle_started",
            "action": "battle_started",
            "battle_type": "box_battle",
            "max_guests": 8,
            "room_id": liveRoomId.value,
          }),
        );
      }
    } catch (_) {}

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token != null && liveRoomId.value.isNotEmpty) {
        apiClient.post(
          Uri.parse(
            '${ApiConstants.baseUrl}live/rooms/${liveRoomId.value}/box-battles/',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"battle_type": "box_battle", "max_guests": 8}),
        );
      }
    } catch (_) {}

    joinSession("box battle");
    navigateTo("LiveBoxBattle");
  }

  void endBoxBattle() {
    isBoxBattleActive.value = false;
    _boxBattleTimer?.cancel();
    joinSession("live");

    try {
      if (_liveWs != null) {
        _liveWs!.add(
          jsonEncode({
            "type": "battle_ended",
            "action": "battle_ended",
            "room_id": liveRoomId.value,
          }),
        );
      }
    } catch (_) {}

    navigateTo("LiveStream");
    Get.snackbar(
      "Box Battle Ended",
      "Returned to standard live stream",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
  }

  void removeBoxGuest(int slotNumber) {
    final index = boxSlots.indexWhere((s) => s['slot_number'] == slotNumber);
    if (index != -1) {
      final slot = Map<String, dynamic>.from(boxSlots[index]);
      final uid = slot['uid'];
      if (uid != null && uid is int) {
        remoteUids.remove(uid);
      }
      boxSlots[index] = {
        'slot_number': slotNumber,
        'status': 'VACANT',
        'uid': null,
        'guest_id': null,
        'username': '',
        'gift_total': 0,
        'bonus_total': 0,
        'mic_on': true,
        'camera_on': true,
      };

      try {
        if (_liveWs != null) {
          _liveWs!.add(
            jsonEncode({
              "type": "guest_removed",
              "action": "guest_removed",
              "slot_number": slotNumber,
              "guest_id": uid,
              "room_id": liveRoomId.value,
            }),
          );
        }
      } catch (_) {}

      Get.snackbar(
        "Guest Removed",
        "Slot $slotNumber is now vacant",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  void toggleSlotMic(int slotNumber) {
    final index = boxSlots.indexWhere((s) => s['slot_number'] == slotNumber);
    if (index != -1) {
      final slot = Map<String, dynamic>.from(boxSlots[index]);
      final currentMic = slot['mic_on'] == true;
      slot['mic_on'] = !currentMic;
      boxSlots[index] = slot;
      Get.snackbar(
        "Guest Microphone",
        "Slot $slotNumber mic ${!currentMic ? 'enabled' : 'muted'}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  void toggleSlotCamera(int slotNumber) {
    final index = boxSlots.indexWhere((s) => s['slot_number'] == slotNumber);
    if (index != -1) {
      final slot = Map<String, dynamic>.from(boxSlots[index]);
      final currentCam = slot['camera_on'] == true;
      slot['camera_on'] = !currentCam;
      boxSlots[index] = slot;
      Get.snackbar(
        "Guest Camera",
        "Slot $slotNumber camera ${!currentCam ? 'enabled' : 'disabled'}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  final timerSeconds = 0.obs;

  void toggleTimer() {
    if (timerSeconds.value == 0) {
      timerSeconds.value = 3;
      Get.snackbar(
        "Timer",
        "Timer set to 3 seconds",
        snackPosition: SnackPosition.TOP,
      );
    } else if (timerSeconds.value == 3) {
      timerSeconds.value = 10;
      Get.snackbar(
        "Timer",
        "Timer set to 10 seconds",
        snackPosition: SnackPosition.TOP,
      );
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

  // ==================== LIVE QUIZ GAME METHODS ====================

  /// Initialize or join Quiz Game instance for current live room
  Future<void> initOrJoinQuizGame([String? targetLiveId]) async {
    if (quizGameId.value.isNotEmpty && _quizWs != null) {
      return;
    }
    final roomId = (targetLiveId != null && targetLiveId.isNotEmpty)
        ? targetLiveId
        : (liveRoomId.value.isNotEmpty
              ? liveRoomId.value
              : 'cf50c1d8-0a2e-4dd8-8cc9-a5916a0bb62d');
    if (liveRoomId.value.isEmpty) {
      liveRoomId.value = roomId;
    }
    print("[DEBUG LIVE QUIZ] Initializing Quiz Game for room: $roomId");

    try {
      // 1. Fetch available categories from API
      await fetchQuizCategories();

      // 2. Connect 100% Real-Time WebSocket Live Quiz Engine
      // Connecting via live_room_id automatically discovers or initializes the active quiz session
      _connectQuizWebSocket();

      // 3. Fallback / supplementary createQuizGame via REST
      final gameRes = await gameService.createQuizGame(roomId);
      if (gameRes != null) {
        final id = gameRes['id'] ?? gameRes['game_id'];
        if (id != null) {
          quizGameId.value = id.toString();
        }
        quizGameStatus.value =
            gameRes['status']?.toString() ?? 'WAITING_FOR_CATEGORY';
        print(
          "[DEBUG LIVE QUIZ] Quiz game created/found. ID: ${quizGameId.value}, status: ${quizGameStatus.value}",
        );

        if (gameRes['active_category'] is Map) {
          selectedQuizCategoryId.value =
              gameRes['active_category']['id']?.toString() ?? '';
          selectedQuizCategoryName.value =
              gameRes['active_category']['name']?.toString() ?? '';
        }

        if (gameRes['participants'] is List) {
          quizParticipants.value = List<Map<String, dynamic>>.from(
            gameRes['participants'],
          );
        }

        if (gameRes['active_round'] is Map) {
          final round = gameRes['active_round'];
          activeQuizRoundId.value =
              (round['id'] ?? round['round_id'])?.toString() ?? '';
          activeQuizRoundNo.value = round['round_no'] ?? 1;

          if (round['question'] is Map) {
            activeQuizQuestion.value = Map<String, dynamic>.from(
              round['question'],
            );
            List<dynamic>? answersList;
            if (round['question']['answers'] is List &&
                (round['question']['answers'] as List).isNotEmpty) {
              answersList = round['question']['answers'];
            } else if (round['answers'] is List &&
                (round['answers'] as List).isNotEmpty) {
              answersList = round['answers'];
            }
            if (answersList != null) {
              activeQuizAnswers.value = List<Map<String, dynamic>>.from(
                answersList,
              );
            }
          }
        }
      }

      // If category not selected yet, pick first category returned from API
      if (selectedQuizCategoryId.value.isEmpty && quizCategories.isNotEmpty) {
        selectedQuizCategoryId.value =
            quizCategories.first['id']?.toString() ?? '';
        selectedQuizCategoryName.value =
            quizCategories.first['name']?.toString() ?? '';
      }
    } catch (e) {
      print("[DEBUG LIVE QUIZ] initOrJoinQuizGame error: $e");
    }
  }

  /// 1. Fetch active quiz categories from backend
  Future<void> fetchQuizCategories() async {
    final roomId = liveRoomId.value.isNotEmpty
        ? liveRoomId.value
        : 'cf50c1d8-0a2e-4dd8-8cc9-a5916a0bb62d';
    try {
      isLoadingQuizCategories.value = true;
      final cats = await gameService.getQuizCategories(roomId);
      print(
        "[DEBUG LIVE QUIZ] Fetched ${cats.length} quiz categories from API",
      );
      if (cats.isNotEmpty) {
        quizCategories.value = cats;
        if (selectedQuizCategoryId.value.isEmpty) {
          selectedQuizCategoryId.value = cats.first['id'].toString();
          selectedQuizCategoryName.value = cats.first['name'].toString();
        }
      }
    } catch (e) {
      print("[DEBUG LIVE QUIZ] fetchQuizCategories error: $e");
    } finally {
      isLoadingQuizCategories.value = false;
    }
  }

  /// 2. Host selects and locks category
  Future<void> lockQuizCategory(String categoryId, String categoryName) async {
    selectedQuizCategoryId.value = categoryId;
    selectedQuizCategoryName.value = categoryName;
    quizGameStatus.value = 'CATEGORY_LOCKED';

    print("[DEBUG LIVE QUIZ] Locking category: $categoryName ($categoryId)");

    // 1. Authoritative WebSocket action
    _sendQuizWsAction({'action': 'lock_category', 'category_id': categoryId});

    // 2. HTTP Fallback
    if (quizGameId.value.isNotEmpty) {
      gameService.lockQuizCategory(quizGameId.value, categoryId);
    }

    Get.snackbar(
      "Category Selected",
      "Quiz Category: $categoryName",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
  }

  /// 3. Host starts next 30-second round
  Future<void> startQuizRound() async {
    if (quizGameId.value.isEmpty && liveRoomId.value.isEmpty) {
      await initOrJoinQuizGame();
    }

    // Automatically lock category if still waiting for category
    if (selectedQuizCategoryId.value.isNotEmpty &&
        quizGameStatus.value == 'WAITING_FOR_CATEGORY') {
      await lockQuizCategory(
        selectedQuizCategoryId.value,
        selectedQuizCategoryName.value,
      );
    }

    // Reset round answers & choices locally while waiting for server event
    selectedAnswerOption.value = '';
    isAnswerSubmitted.value = false;
    correctAnswerOption.value = '';
    isQuizScored.value = false;
    firstCorrectUserId.value = null;

    print("[DEBUG LIVE QUIZ] Starting round via WebSocket");

    // 1. Authoritative WebSocket action
    _sendQuizWsAction({'action': 'start_round'});

    // 2. Fallback REST call
    if (quizGameId.value.isNotEmpty) {
      try {
        final res = await gameService.startQuizRound(quizGameId.value);
        if (res != null) {
          activeQuizRoundId.value = res['id']?.toString() ?? '';
          activeQuizRoundNo.value =
              res['round_no'] ?? (activeQuizRoundNo.value + 1);
          quizGameStatus.value = 'QUESTION_ACTIVE';
          isQuizRoundActive.value = true;

          if (res['question'] is Map) {
            activeQuizQuestion.value = Map<String, dynamic>.from(
              res['question'],
            );
            List<dynamic>? answersList;
            if (res['question']['answers'] is List &&
                (res['question']['answers'] as List).isNotEmpty) {
              answersList = res['question']['answers'];
            } else if (res['answers'] is List &&
                (res['answers'] as List).isNotEmpty) {
              answersList = res['answers'];
            }
            if (answersList != null) {
              activeQuizAnswers.value = List<Map<String, dynamic>>.from(
                answersList,
              );
            }
          }

          if (res['deadline_at'] != null) {
            quizDeadlineAt.value = DateTime.tryParse(
              res['deadline_at'].toString(),
            );
          }

          _startQuizCountdownTimer(30);
        }
      } catch (e) {
        print("[DEBUG LIVE QUIZ] REST startQuizRound fallback error: $e");
      }
    }
  }

  void _startQuizCountdownTimer(int seconds) {
    _quizRoundTimer?.cancel();
    quizTimerSeconds.value = seconds;
    quizTimerText.value = "00:${seconds.toString().padLeft(2, '0')}";

    _quizRoundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (quizTimerSeconds.value > 1) {
        quizTimerSeconds.value--;
        quizTimerText.value =
            "00:${quizTimerSeconds.value.toString().padLeft(2, '0')}";
      } else {
        quizTimerSeconds.value = 0;
        quizTimerText.value = "00:00";
        timer.cancel();
        isQuizRoundActive.value = false;

        // Auto-score round when 30-second server deadline expires
        scoreQuizRound();
      }
    });
  }

  /// 4. Participant submits an answer (A-D)
  Future<void> submitQuizAnswer(String optionCode) async {
    if (isAnswerSubmitted.value || !isQuizRoundActive.value) return;

    selectedAnswerOption.value = optionCode;
    isAnswerSubmitted.value = true;
    final userId = userProfile.value?.id ?? 1;
    final key =
        'ans_user${userId}_r${activeQuizRoundNo.value}_req${DateTime.now().millisecondsSinceEpoch}';

    print(
      "[DEBUG LIVE QUIZ] Submitting answer via WS: $optionCode for round: ${activeQuizRoundId.value}",
    );

    // 1. Authoritative WebSocket action
    _sendQuizWsAction({
      'action': 'submit_answer',
      'round_id': activeQuizRoundId.value,
      'option_code': optionCode,
      'idempotency_key': key,
    });

    // 2. Fallback REST
    if (quizGameId.value.isNotEmpty && activeQuizRoundId.value.isNotEmpty) {
      try {
        gameService.submitQuizAnswer(
          quizGameId.value,
          activeQuizRoundId.value,
          optionCode,
          idempotencyKey: key,
        );
      } catch (e) {
        print("[DEBUG LIVE QUIZ] submitQuizAnswer error: $e");
      }
    }
  }

  /// 5. Score round and distribute rewards
  Future<void> scoreQuizRound() async {
    if (isQuizScored.value) return;
    isQuizScored.value = true;
    _quizRoundTimer?.cancel();
    isQuizRoundActive.value = false;

    print("[DEBUG LIVE QUIZ] Scoring round via WS: ${activeQuizRoundId.value}");

    // 1. Authoritative WebSocket action
    _sendQuizWsAction({
      'action': 'score_round',
      'round_id': activeQuizRoundId.value,
    });

    // 2. Fallback REST
    if (quizGameId.value.isNotEmpty && activeQuizRoundId.value.isNotEmpty) {
      try {
        final res = await gameService.scoreQuizRound(
          quizGameId.value,
          activeQuizRoundId.value,
        );
        if (res != null) {
          correctAnswerOption.value = res['correct_option']?.toString() ?? '';
          firstCorrectUserId.value = res['first_correct_user_id'] is int
              ? res['first_correct_user_id']
              : int.tryParse(res['first_correct_user_id']?.toString() ?? '');

          if (res['rewards'] is List) {
            quizRewards.value = List<Map<String, dynamic>>.from(res['rewards']);

            for (final r in quizRewards) {
              final uid = r['user_id'];
              final idx = quizParticipants.indexWhere(
                (p) => p['user_id'] == uid,
              );
              if (idx != -1) {
                final currentB =
                    double.tryParse(
                      quizParticipants[idx]['platform_reward_b']?.toString() ??
                          '0',
                    ) ??
                    0;
                final added =
                    double.tryParse(r['amount']?.toString() ?? '0') ?? 0;
                quizParticipants[idx]['platform_reward_b'] = (currentB + added);
                quizParticipants[idx]['is_correct'] = true;
              }
            }
            quizParticipants.refresh();
          }
        }
      } catch (e) {
        print("[DEBUG LIVE QUIZ] scoreQuizRound error: $e");
      }
    }
  }

  /// 6. Send fan gifts ($a$) to a quiz guest
  Future<void> sendQuizGift(
    int recipientUserId,
    double amount, {
    String giftType = 'GALAXY_STAR',
  }) async {
    print(
      "[DEBUG LIVE QUIZ] Sending gift via WS to $recipientUserId ($amount)",
    );

    // 1. Authoritative WebSocket action
    _sendQuizWsAction({
      'action': 'send_gift',
      'recipient_user_id': recipientUserId,
      'amount': amount,
      'gift_type': giftType,
    });

    // 2. Fallback REST
    if (quizGameId.value.isNotEmpty) {
      try {
        final res = await gameService.sendQuizGift(
          quizGameId.value,
          recipientUserId: recipientUserId,
          amount: amount,
          giftType: giftType,
        );
        if (res != null) {
          final idx = quizParticipants.indexWhere(
            (p) => p['user_id'] == recipientUserId,
          );
          if (idx != -1) {
            final currentA =
                double.tryParse(
                  quizParticipants[idx]['fan_gifts_a']?.toString() ?? '0',
                ) ??
                0;
            quizParticipants[idx]['fan_gifts_a'] = currentA + amount;
            quizParticipants.refresh();
          }
          Get.snackbar(
            "Gift Sent!",
            "Sent $giftType to participant",
            backgroundColor: Colors.white,
            colorText: Colors.black,
          );
        }
      } catch (e) {
        print("[DEBUG LIVE QUIZ] sendQuizGift error: $e");
      }
    }
  }

  /// 7. Recover full authoritative state
  Future<void> recoverQuizState() async {
    if (quizGameId.value.isEmpty) return;
    _sendQuizWsAction({'action': 'get_state'});
    try {
      final state = await gameService.getQuizState(quizGameId.value);
      if (state != null) {
        quizGameStatus.value = state['status']?.toString() ?? 'ACTIVE';

        if (state['active_category'] is Map) {
          selectedQuizCategoryId.value =
              state['active_category']['id']?.toString() ?? '';
          selectedQuizCategoryName.value =
              state['active_category']['name']?.toString() ?? '';
        }

        if (state['active_round'] is Map) {
          final round = state['active_round'];
          activeQuizRoundId.value = round['round_id']?.toString() ?? '';
          activeQuizRoundNo.value = round['round_no'] ?? 1;

          if (round['question'] is Map) {
            activeQuizQuestion.value = Map<String, dynamic>.from(
              round['question'],
            );
            if (round['question']['answers'] is List) {
              activeQuizAnswers.value = List<Map<String, dynamic>>.from(
                round['question']['answers'],
              );
            }
          }

          if (round['status'] == 'QUESTION_ACTIVE') {
            isQuizRoundActive.value = true;
            final deadline = DateTime.tryParse(
              round['deadline_at']?.toString() ?? '',
            );
            if (deadline != null) {
              final rem = deadline.difference(DateTime.now()).inSeconds;
              if (rem > 0) {
                _startQuizCountdownTimer(rem);
              }
            }
          }
        }

        if (state['participants'] is List) {
          quizParticipants.value = List<Map<String, dynamic>>.from(
            state['participants'],
          );
        }
      }
    } catch (e) {
      print("[DEBUG LIVE QUIZ] recoverQuizState error: $e");
    }
  }

  /// 8. End Quiz Game Session
  Future<void> endQuizGame() async {
    _quizRoundTimer?.cancel();
    isQuizRoundActive.value = false;

    print("[DEBUG LIVE QUIZ] Ending quiz game via WS");

    // 1. Authoritative WebSocket action
    _sendQuizWsAction({'action': 'end_game'});

    // 2. Fallback REST
    if (quizGameId.value.isNotEmpty) {
      try {
        final res = await gameService.endQuizGame(quizGameId.value);
        if (res != null) {
          totalFanGiftsEarned.value =
              double.tryParse(res['total_fan_gifts']?.toString() ?? '0') ?? 0;
          totalReleasedRewards.value =
              double.tryParse(
                res['total_released_rewards']?.toString() ?? '0',
              ) ??
              0;
          hostShareEarnings.value =
              double.tryParse(res['host_share_earnings']?.toString() ?? '0') ??
              0;

          _showQuizEndSummaryDialog();
          return;
        }
      } catch (e) {
        print("[DEBUG LIVE QUIZ] endQuizGame error: $e");
      }
    }

    _showQuizEndSummaryDialog();
  }

  void _showQuizEndSummaryDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Quiz Session Ended 🏆",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                Icons.card_giftcard,
                "Total Fan Gifts (a)",
                "${totalFanGiftsEarned.value}",
              ),
              const SizedBox(height: 10),
              _buildStatRow(
                Icons.emoji_events_outlined,
                "Platform Rewards (b)",
                "${totalReleasedRewards.value}",
              ),
              const SizedBox(height: 10),
              _buildStatRow(
                Icons.monetization_on_outlined,
                "Host Earnings",
                "${hostShareEarnings.value}",
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1818),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: () {
                  Get.back();
                  navigateTo("LiveStream");
                },
                child: const Text(
                  "Return to Live",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==================== LIVE QUIZ WEBSOCKET ====================

  void _connectQuizWebSocket() {
    final roomId = liveRoomId.value.isNotEmpty
        ? liveRoomId.value
        : 'cf50c1d8-0a2e-4dd8-8cc9-a5916a0bb62d';
    if (_quizWs != null) {
      try {
        _quizWs!.close();
      } catch (_) {}
      _quizWs = null;
    }

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';

      // Dual endpoint support:
      // ws://<host>/ws/live/<live_room_id>/quiz/?token=<JWT> (automatically discovers or initializes quiz session)
      // ws://<host>/ws/live-quiz/<game_id>/?token=<JWT>
      final String wsUrl;
      if (roomId.isNotEmpty) {
        wsUrl =
            '$wsScheme://${parsed.host}$portStr/ws/live/$roomId/quiz/?token=${token ?? ''}';
      } else if (quizGameId.value.isNotEmpty) {
        wsUrl =
            '$wsScheme://${parsed.host}$portStr/ws/live-quiz/${quizGameId.value}/?token=${token ?? ''}';
      } else {
        return;
      }

      print("[DEBUG LIVE QUIZ WS] Connecting to Quiz WebSocket: $wsUrl");
      WebSocket.connect(wsUrl)
          .then((ws) {
            _quizWs = ws;
            print("[DEBUG LIVE QUIZ WS] Connected successfully!");

            // Auto join game as HOST
            _sendQuizWsAction({
              'action': 'join_game',
              'seat': 'HOST',
              'role': 'HOST',
            });

            ws.listen(
              (event) {
                try {
                  final data = jsonDecode(event.toString());
                  print("[DEBUG LIVE QUIZ WS Event]: $data");
                  if (data is Map<String, dynamic>) {
                    _handleQuizWsEvent(data);
                  }
                } catch (e) {
                  print("[DEBUG LIVE QUIZ WS] Parse error: $e");
                }
              },
              onError: (err) {
                print("[DEBUG LIVE QUIZ WS] Stream error: $err");
                _quizWs = null;
              },
              onDone: () {
                print("[DEBUG LIVE QUIZ WS] Stream closed");
                _quizWs = null;
              },
            );
          })
          .catchError((err) {
            print("[DEBUG LIVE QUIZ WS] Connect error: $err");
            // Fallback: if connecting via live_room_id failed and quizGameId is known, try /ws/live-quiz/<game_id>/
            if (quizGameId.value.isNotEmpty && !wsUrl.contains('live-quiz')) {
              final fallbackUrl =
                  '$wsScheme://${parsed.host}$portStr/ws/live-quiz/${quizGameId.value}/?token=${token ?? ''}';
              print("[DEBUG LIVE QUIZ WS] Trying fallback URL: $fallbackUrl");
              WebSocket.connect(fallbackUrl)
                  .then((ws) {
                    _quizWs = ws;
                    _sendQuizWsAction({
                      'action': 'join_game',
                      'seat': 'HOST',
                      'role': 'HOST',
                    });
                    ws.listen(
                      (event) {
                        try {
                          final data = jsonDecode(event.toString());
                          if (data is Map<String, dynamic>)
                            _handleQuizWsEvent(data);
                        } catch (_) {}
                      },
                      onError: (_) => _quizWs = null,
                      onDone: () => _quizWs = null,
                    );
                  })
                  .catchError((_) {});
            }
          });
    } catch (e) {
      print("[DEBUG LIVE QUIZ WS] Exception connecting: $e");
    }
  }

  void _sendQuizWsAction(Map<String, dynamic> payload) {
    try {
      if (_quizWs != null) {
        _quizWs!.add(jsonEncode(payload));
        print("[DEBUG LIVE QUIZ WS] Sent action: $payload");
      }
    } catch (e) {
      print("[DEBUG LIVE QUIZ WS] Send error: $e");
    }
  }

  void _handleQuizWsEvent(Map<String, dynamic> data) {
    final event = data['event']?.toString() ?? data['type']?.toString();
    final Map<String, dynamic> payload = data['payload'] is Map
        ? Map<String, dynamic>.from(data['payload'])
        : data;

    print("[DEBUG LIVE QUIZ WS] Handling event: $event");

    switch (event) {
      case 'connection_ack':
      case 'CONNECTED':
        final gId = data['game_id'] ?? payload['game_id'];
        if (gId != null && gId.toString().isNotEmpty) {
          quizGameId.value = gId.toString();
        }
        final rId = data['live_room_id'] ?? payload['live_room_id'];
        if (rId != null && rId.toString().isNotEmpty) {
          liveRoomId.value = rId.toString();
        }
        if (data['state'] is Map) {
          final state = Map<String, dynamic>.from(data['state']);
          if (state['game_id'] != null) {
            quizGameId.value = state['game_id'].toString();
          }
          if (state['status'] != null) {
            quizGameStatus.value = state['status'].toString();
          }
          if (state['active_category'] is Map) {
            final cat = state['active_category'];
            selectedQuizCategoryId.value = cat['id']?.toString() ?? '';
            selectedQuizCategoryName.value = cat['name']?.toString() ?? '';
          }
          if (state['participants'] is List) {
            quizParticipants.value = List<Map<String, dynamic>>.from(
              state['participants'],
            );
          }
          if (state['active_round'] is Map) {
            final round = state['active_round'];
            activeQuizRoundId.value =
                (round['id'] ?? round['round_id'])?.toString() ?? '';
            activeQuizRoundNo.value = round['round_no'] ?? 1;
            if (round['question'] is Map) {
              activeQuizQuestion.value = Map<String, dynamic>.from(
                round['question'],
              );
              if (round['question']['answers'] is List) {
                activeQuizAnswers.value = List<Map<String, dynamic>>.from(
                  round['question']['answers'],
                );
              }
            }
            if (round['answers'] is List && activeQuizAnswers.isEmpty) {
              activeQuizAnswers.value = List<Map<String, dynamic>>.from(
                round['answers'],
              );
            }
            isQuizRoundActive.value = true;
            final duration = round['duration_sec'] ?? 30;
            _startQuizCountdownTimer(duration is int ? duration : 30);
          }
        }
        // Send join_game as HOST
        _sendQuizWsAction({
          'action': 'join_game',
          'seat': 'HOST',
          'role': 'HOST',
        });
        break;

      case 'PARTICIPANT_JOINED':
        final uid = payload['user_id'];
        if (uid != null) {
          final idx = quizParticipants.indexWhere((p) => p['user_id'] == uid);
          if (idx != -1) {
            quizParticipants[idx] = {...quizParticipants[idx], ...payload};
          } else {
            quizParticipants.add(payload);
          }
          quizParticipants.refresh();
        }
        break;

      case 'CATEGORY_LOCKED':
        final catId = payload['category_id']?.toString() ?? '';
        final catName = payload['category_name']?.toString() ?? '';
        if (catId.isNotEmpty) selectedQuizCategoryId.value = catId;
        if (catName.isNotEmpty) selectedQuizCategoryName.value = catName;
        quizGameStatus.value = 'CATEGORY_LOCKED';
        break;

      case 'ROUND_STARTED':
        activeQuizRoundId.value =
            (payload['round_id'] ?? data['round_id'])?.toString() ?? '';
        activeQuizRoundNo.value =
            payload['round_no'] ?? (activeQuizRoundNo.value + 1);
        selectedAnswerOption.value = '';
        isAnswerSubmitted.value = false;
        correctAnswerOption.value = '';
        isQuizScored.value = false;
        firstCorrectUserId.value = null;
        isQuizRoundActive.value = true;

        for (var p in quizParticipants) {
          p.remove('selected_option');
          p.remove('is_correct');
        }
        quizParticipants.refresh();

        final duration = payload['duration_sec'] ?? 30;
        _startQuizCountdownTimer(duration is int ? duration : 30);
        break;

      case 'QUESTION_ACTIVE':
        isQuizRoundActive.value = true;
        if (payload['round_id'] != null) {
          activeQuizRoundId.value = payload['round_id'].toString();
        }
        if (payload['round_no'] != null) {
          activeQuizRoundNo.value = payload['round_no'] is int
              ? payload['round_no']
              : int.tryParse(payload['round_no'].toString()) ?? 1;
        }
        if (payload['question'] is Map) {
          final q = Map<String, dynamic>.from(payload['question']);
          activeQuizQuestion.value = q;
          if (q['answers'] is List) {
            activeQuizAnswers.value = List<Map<String, dynamic>>.from(
              q['answers'],
            );
          }
        }
        if (payload['answers'] is List && activeQuizAnswers.isEmpty) {
          activeQuizAnswers.value = List<Map<String, dynamic>>.from(
            payload['answers'],
          );
        }
        if (_quizRoundTimer == null || !_quizRoundTimer!.isActive) {
          _startQuizCountdownTimer(30);
        }
        break;

      case 'ANSWER_SELECTED':
        final uid = payload['user_id'];
        final option = payload['option_code']?.toString() ?? '';
        final idx = quizParticipants.indexWhere((p) => p['user_id'] == uid);
        if (idx != -1) {
          quizParticipants[idx]['selected_option'] = option;
          quizParticipants.refresh();
        }
        final myUid = userProfile.value?.id;
        if (myUid != null && myUid == uid) {
          selectedAnswerOption.value = option;
          isAnswerSubmitted.value = true;
        }
        break;

      case 'PLAYER_ACTION_REJECTED':
        final reason =
            data['reason']?.toString() ??
            payload['reason']?.toString() ??
            'Action rejected';
        Get.snackbar(
          "Action Rejected",
          reason,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        if (data['error_code'] == 'TIME_EXPIRED' ||
            payload['error_code'] == 'TIME_EXPIRED') {
          isQuizRoundActive.value = false;
        }
        break;

      case 'ANSWER_LOCKED':
        final uid = payload['user_id'];
        final isCorrect =
            payload['result'] == 'CORRECT' || payload['is_correct'] == true;
        final idx = quizParticipants.indexWhere((p) => p['user_id'] == uid);
        if (idx != -1) {
          quizParticipants[idx]['is_correct'] = isCorrect;
          quizParticipants.refresh();
        }
        break;

      case 'REWARD_PENDING':
        print("[DEBUG LIVE QUIZ WS] Reward pending: $payload");
        break;

      case 'ROUND_RESULT':
        isQuizRoundActive.value = false;
        isQuizScored.value = true;
        correctAnswerOption.value = payload['correct_option']?.toString() ?? '';
        firstCorrectUserId.value = payload['first_correct_user_id'] is int
            ? payload['first_correct_user_id']
            : int.tryParse(payload['first_correct_user_id']?.toString() ?? '');
        if (payload['rewards'] is List) {
          final rewardsList = List<Map<String, dynamic>>.from(
            payload['rewards'],
          );
          quizRewards.value = rewardsList;

          for (final r in rewardsList) {
            final uid = r['user_id'];
            final idx = quizParticipants.indexWhere((p) => p['user_id'] == uid);
            if (idx != -1) {
              final currentB =
                  double.tryParse(
                    quizParticipants[idx]['platform_reward_b']?.toString() ??
                        '0',
                  ) ??
                  0;
              final added =
                  double.tryParse(r['amount']?.toString() ?? '0') ?? 0;
              quizParticipants[idx]['platform_reward_b'] = (currentB + added);
              quizParticipants[idx]['is_correct'] = true;
            }
          }
          quizParticipants.refresh();
        }
        break;

      case 'ROUND_ENDED':
        isQuizRoundActive.value = false;
        _quizRoundTimer?.cancel();
        break;

      case 'GIFT_SENT':
        final recipientId = payload['recipient_id'];
        final amount =
            double.tryParse(payload['amount']?.toString() ?? '0') ?? 0;
        final senderName = payload['sender_username']?.toString() ?? 'Fan';
        final giftType = payload['gift_type']?.toString() ?? 'Gift';

        final idx = quizParticipants.indexWhere(
          (p) => p['user_id'] == recipientId,
        );
        if (idx != -1) {
          final newTotal = payload['new_fan_gifts_total'];
          if (newTotal != null) {
            quizParticipants[idx]['fan_gifts_a'] =
                double.tryParse(newTotal.toString()) ?? 0;
          } else {
            final currentA =
                double.tryParse(
                  quizParticipants[idx]['fan_gifts_a']?.toString() ?? '0',
                ) ??
                0;
            quizParticipants[idx]['fan_gifts_a'] = currentA + amount;
          }
          if (payload['guest_display_total'] != null) {
            quizParticipants[idx]['guest_display_total'] =
                payload['guest_display_total'];
          }
          quizParticipants.refresh();
        }

        Get.snackbar(
          "Gift Received! 🎁",
          "$senderName sent $giftType ($amount coins)",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
        break;

      case 'REWARD_RELEASED':
      case 'REWARD_FORFEITED':
      case 'HOST_SHARE':
        print("[DEBUG LIVE QUIZ WS] $event: $payload");
        break;

      case 'GAME_ENDED':
        isQuizRoundActive.value = false;
        _quizRoundTimer?.cancel();
        totalFanGiftsEarned.value =
            double.tryParse(payload['total_fan_gifts']?.toString() ?? '0') ?? 0;
        totalReleasedRewards.value =
            double.tryParse(
              payload['total_released_rewards']?.toString() ?? '0',
            ) ??
            0;
        hostShareEarnings.value =
            double.tryParse(
              payload['host_share_earnings']?.toString() ?? '0',
            ) ??
            0;
        _showQuizEndSummaryDialog();
        break;
    }
  }

  // ==================== LIVE KARAOKE GAME METHODS ====================

  /// Initialize or join Karaoke Game instance for current live room
  Future<void> initOrJoinKaraokeGame([String? targetLiveId]) async {
    if (karaokeGameId.value.isNotEmpty && _karaokeWs != null) {
      return;
    }
    final roomId = (targetLiveId != null && targetLiveId.isNotEmpty)
        ? targetLiveId
        : (liveRoomId.value.isNotEmpty
              ? liveRoomId.value
              : 'a81f7ca6-16f9-42fe-9be0-03c47700d7df');
    if (liveRoomId.value.isEmpty) {
      liveRoomId.value = roomId;
    }
    print("[DEBUG LIVE KARAOKE] Initializing Karaoke Game for room: $roomId");

    try {
      // 1. Fetch available tracks catalog from API
      await fetchKaraokeCatalog();

      // 2. Connect 100% Real-Time WebSocket Karaoke Engine
      _connectKaraokeWebSocket();

      // 3. Fallback / supplementary init via REST API
      final res = await gameService.initOrGetKaraokeGame(roomId);
      if (res != null) {
        final id = res['id'] ?? res['game_id'];
        if (id != null) {
          karaokeGameId.value = id.toString();
        }
        karaokeGameStatus.value =
            res['status']?.toString() ?? 'WAITING_FOR_SINGER';
        print(
          "[DEBUG LIVE KARAOKE] Karaoke game created/found. ID: ${karaokeGameId.value}, status: ${karaokeGameStatus.value}",
        );

        if (res['participants'] is List) {
          karaokeParticipants.value = List<Map<String, dynamic>>.from(
            res['participants'],
          );
        }

        if (res['active_performance'] is Map) {
          final perf = Map<String, dynamic>.from(res['active_performance']);
          karaokeActivePerformance.value = perf;
          karaokePerformanceId.value = perf['id']?.toString() ?? '';
          karaokeCurrentSinger.value =
              perf['performer_username']?.toString() ?? '';
          karaokeCurrentSingerId.value = perf['performer_id'] is int
              ? perf['performer_id']
              : (int.tryParse(perf['performer_id']?.toString() ?? '') ?? 0);
          karaokeCurrentTrackTitle.value =
              perf['track_title']?.toString() ?? '';
          karaokeCurrentTrackArtist.value =
              perf['track_artist']?.toString() ?? '';
          karaokeCurrentTrackType.value =
              perf['content_type']?.toString() ?? 'INSTRUMENTAL';
          karaokeIsRewardEligible.value = perf['is_reward_eligible'] == true;
        }
      }
    } catch (e) {
      print("[DEBUG LIVE KARAOKE] initOrJoinKaraokeGame error: $e");
    }
  }

  /// Connect to Authoritative Real-Time Live Karaoke WebSocket
  void _connectKaraokeWebSocket() {
    if (_karaokeWs != null) {
      try {
        _karaokeWs!.close();
      } catch (_) {}
      _karaokeWs = null;
    }

    try {
      final auth = Get.find<AuthService>();
      final token = auth.accessToken.value;
      final roomId = liveRoomId.value.isNotEmpty
          ? liveRoomId.value
          : 'a81f7ca6-16f9-42fe-9be0-03c47700d7df';

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';

      final String wsUrl;
      if (roomId.isNotEmpty) {
        wsUrl =
            '$wsScheme://${parsed.host}$portStr/ws/live/$roomId/karaoke/?token=${token ?? ''}';
      } else if (karaokeGameId.value.isNotEmpty) {
        wsUrl =
            '$wsScheme://${parsed.host}$portStr/ws/live-karaoke/${karaokeGameId.value}/?token=${token ?? ''}';
      } else {
        return;
      }

      print("[DEBUG LIVE KARAOKE WS] Connecting to Karaoke WebSocket: $wsUrl");
      WebSocket.connect(wsUrl)
          .then((ws) {
            _karaokeWs = ws;
            print("[DEBUG LIVE KARAOKE WS] Connected successfully!");

            // Request authoritative state
            _sendKaraokeWsAction({'action': 'get_state'});

            ws.listen(
              (event) {
                try {
                  final data = jsonDecode(event.toString());
                  print("[DEBUG LIVE KARAOKE WS Event]: $data");
                  if (data is Map<String, dynamic>) {
                    _handleKaraokeWsEvent(data);
                  }
                } catch (e) {
                  print("[DEBUG LIVE KARAOKE WS] Parse error: $e");
                }
              },
              onError: (err) {
                print("[DEBUG LIVE KARAOKE WS] Stream error: $err");
                _karaokeWs = null;
              },
              onDone: () {
                print("[DEBUG LIVE KARAOKE WS] Stream closed");
                _karaokeWs = null;
              },
            );
          })
          .catchError((err) {
            print("[DEBUG LIVE KARAOKE WS] Connect error: $err");
            if (karaokeGameId.value.isNotEmpty &&
                !wsUrl.contains('live-karaoke')) {
              final fallbackUrl =
                  '$wsScheme://${parsed.host}$portStr/ws/live-karaoke/${karaokeGameId.value}/?token=${token ?? ''}';
              print(
                "[DEBUG LIVE KARAOKE WS] Trying fallback URL: $fallbackUrl",
              );
              WebSocket.connect(fallbackUrl)
                  .then((ws) {
                    _karaokeWs = ws;
                    _sendKaraokeWsAction({'action': 'get_state'});
                    ws.listen(
                      (event) {
                        try {
                          final data = jsonDecode(event.toString());
                          if (data is Map<String, dynamic>)
                            _handleKaraokeWsEvent(data);
                        } catch (_) {}
                      },
                      onError: (_) => _karaokeWs = null,
                      onDone: () => _karaokeWs = null,
                    );
                  })
                  .catchError((_) {});
            }
          });
    } catch (e) {
      print("[DEBUG LIVE KARAOKE WS] Exception connecting: $e");
    }
  }

  void _sendKaraokeWsAction(Map<String, dynamic> payload) {
    try {
      if (_karaokeWs != null) {
        _karaokeWs!.add(jsonEncode(payload));
        print("[DEBUG LIVE KARAOKE WS] Sent action: $payload");
      }
    } catch (e) {
      print("[DEBUG LIVE KARAOKE WS] Send error: $e");
    }
  }

  void _handleKaraokeWsEvent(Map<String, dynamic> data) {
    final event = data['event']?.toString() ?? data['type']?.toString();
    final Map<String, dynamic> payload = data['payload'] is Map
        ? Map<String, dynamic>.from(data['payload'])
        : data;

    print("[DEBUG LIVE KARAOKE WS] Processing event: $event");

    switch (event) {
      case 'connection_ack':
      case 'CONNECTED':
        if (data['game_id'] != null) {
          karaokeGameId.value = data['game_id'].toString();
        }
        if (data['state'] is Map) {
          final state = Map<String, dynamic>.from(data['state']);
          karaokeGameStatus.value =
              state['status']?.toString() ?? 'WAITING_FOR_SINGER';
          if (state['participants'] is List) {
            karaokeParticipants.value = List<Map<String, dynamic>>.from(
              state['participants'],
            );
          }
          if (state['active_performance'] is Map) {
            final perf = Map<String, dynamic>.from(state['active_performance']);
            karaokeActivePerformance.value = perf;
            karaokePerformanceId.value = perf['id']?.toString() ?? '';
            karaokeCurrentSinger.value =
                perf['performer_username']?.toString() ?? '';
            karaokeCurrentSingerId.value = perf['performer_id'] is int
                ? perf['performer_id']
                : (int.tryParse(perf['performer_id']?.toString() ?? '') ?? 0);
            karaokeCurrentTrackTitle.value =
                perf['track_title']?.toString() ?? '';
            karaokeCurrentTrackArtist.value =
                perf['track_artist']?.toString() ?? '';
            karaokeCurrentTrackType.value =
                perf['content_type']?.toString() ?? 'INSTRUMENTAL';
            karaokeIsRewardEligible.value = perf['is_reward_eligible'] == true;
          }
        }
        break;

      case 'SINGER_ASSIGNED':
        karaokePerformanceId.value =
            payload['performance_id']?.toString() ?? '';
        karaokeCurrentSinger.value =
            payload['performer_username']?.toString() ?? 'Guest';
        karaokeCurrentSingerId.value = payload['performer_id'] is int
            ? payload['performer_id']
            : (int.tryParse(payload['performer_id']?.toString() ?? '') ?? 0);
        karaokeCurrentSingerSeat.value = payload['seat']?.toString() ?? '1';
        karaokeGameStatus.value = 'SINGER_ASSIGNED';

        // Update participant in grid
        final uid = karaokeCurrentSingerId.value;
        final idx = karaokeParticipants.indexWhere((p) => p['user_id'] == uid);
        if (idx != -1) {
          karaokeParticipants[idx]['role'] = 'SINGER';
          karaokeParticipants.refresh();
        }

        Get.snackbar(
          "Singer Assigned 🎤",
          "@${karaokeCurrentSinger.value} is up next to sing!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.pinkAccent,
          colorText: Colors.white,
        );
        break;

      case 'TRACK_SELECTED':
        karaokeCurrentTrackId.value = payload['track_id']?.toString() ?? '';
        karaokeCurrentTrackTitle.value = payload['title']?.toString() ?? '';
        karaokeCurrentTrackArtist.value = payload['artist']?.toString() ?? '';
        karaokeCurrentTrackType.value =
            payload['type']?.toString() ?? 'INSTRUMENTAL';
        karaokeDurationMs.value = payload['duration_ms'] ?? 200000;
        karaokeIsRewardEligible.value = payload['is_reward_eligible'] == true;
        karaokeGameStatus.value = 'TRACK_SELECTED';

        Get.snackbar(
          "Track Selected 🎵",
          "${karaokeCurrentTrackTitle.value} by ${karaokeCurrentTrackArtist.value}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.deepPurpleAccent,
          colorText: Colors.white,
        );
        break;

      case 'PLAYBACK_PREPARED':
        karaokePlaybackToken.value =
            payload['playback_token']?.toString() ?? '';
        karaokeAudioUrl.value = payload['audio_url']?.toString() ?? '';
        karaokeDurationMs.value =
            payload['duration_ms'] ?? karaokeDurationMs.value;
        if (payload['lyrics'] is List) {
          karaokeLyricsList.value = List<Map<String, dynamic>>.from(
            payload['lyrics'],
          );
        }
        karaokeGameStatus.value = 'PLAYBACK_PREPARED';
        break;

      case 'PERFORMANCE_STARTED':
        isKaraokePerformanceActive.value = true;
        karaokeGameStatus.value = 'PERFORMANCE_ACTIVE';
        final durMs = payload['duration_ms'] ?? karaokeDurationMs.value;
        final durSec = (durMs is int && durMs > 0) ? (durMs ~/ 1000) : 180;
        _startKaraokeCountdownTimer(durSec);
        final playUrl =
            payload['audio_url']?.toString() ?? karaokeAudioUrl.value;
        if (playUrl.isNotEmpty) karaokeAudioUrl.value = playUrl;
        _playKaraokeAudio(karaokeAudioUrl.value);
        break;

      case 'LYRIC_LINE_CHANGED':
        karaokeCurrentLyricLine.value =
            payload['line_no'] ?? (karaokeCurrentLyricLine.value + 1);
        karaokeCurrentLyricText.value = payload['text']?.toString() ?? '';
        break;

      case 'PERFORMANCE_COMPLETED':
        isKaraokePerformanceActive.value = false;
        _karaokeTimer?.cancel();
        _stopKaraokeAudio();
        karaokeGameStatus.value = 'COMPLETED';
        Get.snackbar(
          "Performance Completed! 🌟",
          "Bravo! Song performance finished.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        break;

      case 'REWARD_PENDING':
        karaokeHeldReward.value =
            double.tryParse(payload['amount']?.toString() ?? '3.0') ?? 3.0;
        final rUid = payload['user_id'];
        final rIdx = karaokeParticipants.indexWhere(
          (p) => p['user_id'] == rUid,
        );
        if (rIdx != -1) {
          final curB =
              double.tryParse(
                karaokeParticipants[rIdx]['platform_reward_b']?.toString() ??
                    '0',
              ) ??
              0;
          karaokeParticipants[rIdx]['platform_reward_b'] =
              (curB + karaokeHeldReward.value).toStringAsFixed(2);
          karaokeParticipants.refresh();
        }
        Get.snackbar(
          "Reward on Hold ⏳",
          "Earned ${karaokeHeldReward.value} coins (Platform Reward b on hold until 1000 fan threshold)",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
        );
        break;

      case 'REWARD_RELEASED':
        Get.snackbar(
          "Reward Released! 💰",
          "Threshold satisfied! Held rewards released to wallet.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        break;

      case 'REWARD_FORFEITED':
        Get.snackbar(
          "Reward Forfeited ⚠️",
          "Fan gifts under 1000 threshold. Platform reward forfeited.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        break;

      case 'GIFT_SENT':
        final recId = payload['receiver_user_id'] ?? payload['recipient_id'];
        final amt = double.tryParse(payload['amount']?.toString() ?? '0') ?? 0;
        final gIdx = karaokeParticipants.indexWhere(
          (p) => p['user_id'] == recId,
        );
        if (gIdx != -1) {
          final curA =
              double.tryParse(
                karaokeParticipants[gIdx]['fan_gifts_a']?.toString() ?? '0',
              ) ??
              0;
          karaokeParticipants[gIdx]['fan_gifts_a'] = (curA + amt)
              .toStringAsFixed(2);
          karaokeParticipants.refresh();
        }
        karaokeTotalFanGifts.value += amt;
        break;

      case 'GAME_ENDED':
        isKaraokePerformanceActive.value = false;
        _karaokeTimer?.cancel();
        _stopKaraokeAudio();
        karaokeGameStatus.value = 'ENDED';
        karaokeTotalFanGifts.value =
            double.tryParse(payload['total_fan_gifts']?.toString() ?? '0') ??
            karaokeTotalFanGifts.value;
        karaokeTotalReleasedRewards.value =
            double.tryParse(
              payload['total_released_rewards']?.toString() ?? '0',
            ) ??
            0;
        karaokeTotalForfeitedRewards.value =
            double.tryParse(
              payload['total_forfeited_rewards']?.toString() ?? '0',
            ) ??
            0;
        karaokeHostShareEarnings.value =
            double.tryParse(
              payload['host_share_earnings']?.toString() ?? '0',
            ) ??
            0;
        _showKaraokeEndSummaryDialog();
        break;
    }
  }

  void _startKaraokeCountdownTimer(int totalSec) {
    _karaokeTimer?.cancel();
    karaokeTimerSeconds.value = totalSec;
    karaokeTimerText.value =
        '${(totalSec ~/ 60).toString().padLeft(2, '0')}:${(totalSec % 60).toString().padLeft(2, '0')}';

    _karaokeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (karaokeTimerSeconds.value > 1) {
        karaokeTimerSeconds.value--;
        final m = karaokeTimerSeconds.value ~/ 60;
        final s = karaokeTimerSeconds.value % 60;
        karaokeTimerText.value =
            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      } else {
        karaokeTimerSeconds.value = 0;
        karaokeTimerText.value = '00:00';
        isKaraokePerformanceActive.value = false;
        t.cancel();
      }
    });
  }

  /// Browse Admin-Published Music or Instrumental tracks from API
  Future<void> fetchKaraokeCatalog({String? type, String? query}) async {
    isKaraokeCatalogLoading.value = true;
    final catType = type ?? selectedKaraokeCategory.value;
    final rId = liveRoomId.value.isNotEmpty
        ? liveRoomId.value
        : 'a81f7ca6-16f9-42fe-9be0-03c47700d7df';
    try {
      var list = await gameService.getKaraokeCatalog(
        rId,
        type: catType,
        q: query,
      );
      if (list.isEmpty && rId != 'a81f7ca6-16f9-42fe-9be0-03c47700d7df') {
        list = await gameService.getKaraokeCatalog(
          'a81f7ca6-16f9-42fe-9be0-03c47700d7df',
          type: catType,
          q: query,
        );
      }
      if (list.isEmpty && (query == null || query.isEmpty)) {
        list = await gameService.getKaraokeCatalog(rId);
        if (list.isEmpty && rId != 'a81f7ca6-16f9-42fe-9be0-03c47700d7df') {
          list = await gameService.getKaraokeCatalog(
            'a81f7ca6-16f9-42fe-9be0-03c47700d7df',
          );
        }
      }

      karaokeCatalog.value = list;

      // Auto-load first track details and lyrics if none currently active
      if (karaokeCurrentTrackId.value.isEmpty && list.isNotEmpty) {
        final first = list.first;
        karaokeCurrentTrackId.value = first['id']?.toString() ?? '';
        karaokeCurrentTrackTitle.value = first['title']?.toString() ?? '';
        karaokeCurrentTrackArtist.value = first['artist']?.toString() ?? '';
        karaokeCurrentTrackType.value =
            first['content_type']?.toString() ?? 'INSTRUMENTAL';
        karaokeDurationMs.value = first['duration_ms'] ?? 200000;
        if (first['audio_url'] != null) {
          karaokeAudioUrl.value = first['audio_url'].toString();
        }
        if (first['lyric_segments'] is List) {
          karaokeLyricsList.value = List<Map<String, dynamic>>.from(
            first['lyric_segments'],
          );
          if (karaokeLyricsList.isNotEmpty) {
            karaokeCurrentLyricText.value = "🎵 Ready: ${first['title']}";
            karaokeNextLyricText.value =
                karaokeLyricsList.first['text']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      print("[DEBUG LIVE KARAOKE] fetchKaraokeCatalog error: $e");
      karaokeCatalog.value = [];
    } finally {
      isKaraokeCatalogLoading.value = false;
    }
  }

  /// Change Karaoke playlist category (Music vs Instrumentals)
  void setKaraokeCategory(String category) {
    selectedKaraokeCategory.value = category;
    fetchKaraokeCatalog(type: category);
  }

  /// Host Assigns Singer Slot
  Future<void> assignKaraokeSinger(int guestUserId, String seat) async {
    _sendKaraokeWsAction({
      "action": "assign_singer",
      "guest_user_id": guestUserId,
      "seat": seat,
    });
    if (karaokeGameId.value.isNotEmpty) {
      await gameService.assignKaraokeSinger(
        karaokeGameId.value,
        guestUserId: guestUserId,
        seat: seat,
      );
    }
  }

  /// Assigned Guest Selects Track
  Future<void> selectKaraokeTrack(String trackId, String contentType) async {
    Map<String, dynamic>? selected;
    for (final t in karaokeCatalog) {
      if (t['id']?.toString() == trackId) {
        selected = t;
        break;
      }
    }
    if (selected != null) {
      karaokeCurrentTrackId.value = trackId;
      karaokeCurrentTrackTitle.value = selected['title']?.toString() ?? '';
      karaokeCurrentTrackArtist.value = selected['artist']?.toString() ?? '';
      karaokeCurrentTrackType.value = contentType;
      karaokeDurationMs.value = selected['duration_ms'] ?? 200000;
      if (selected['audio_url'] != null) {
        karaokeAudioUrl.value = selected['audio_url'].toString();
      }
      if (selected['lyric_segments'] is List) {
        karaokeLyricsList.value = List<Map<String, dynamic>>.from(
          selected['lyric_segments'],
        );
        if (karaokeLyricsList.isNotEmpty) {
          karaokeCurrentLyricText.value = "🎵 Ready: ${selected['title']}";
          karaokeNextLyricText.value =
              karaokeLyricsList.first['text']?.toString() ?? '';
        }
      }
    }

    _sendKaraokeWsAction({
      "action": "select_track",
      "performance_id": karaokePerformanceId.value,
      "track_id": trackId,
      "content_type": contentType,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      await gameService.selectKaraokeTrack(
        karaokePerformanceId.value,
        trackId: trackId,
        contentType: contentType,
      );
    }
  }

  /// Prepare Playback Session
  Future<void> prepareKaraokePlayback() async {
    _sendKaraokeWsAction({
      "action": "prepare_playback",
      "performance_id": karaokePerformanceId.value,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      await gameService.prepareKaraokePlayback(karaokePerformanceId.value);
    }
  }

  /// Start Performance
  Future<void> startKaraokePerformance() async {
    isKaraokePerformanceActive.value = true;
    karaokeGameStatus.value = 'PERFORMANCE_ACTIVE';
    final durSec = (karaokeDurationMs.value > 0)
        ? (karaokeDurationMs.value ~/ 1000)
        : 200;
    _startKaraokeCountdownTimer(durSec);
    if (karaokeAudioUrl.value.isNotEmpty) {
      _playKaraokeAudio(karaokeAudioUrl.value);
    }

    _sendKaraokeWsAction({
      "action": "start_performance",
      "performance_id": karaokePerformanceId.value,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      await gameService.startKaraokePerformance(karaokePerformanceId.value);
    }
  }

  /// Lyric Synchronization
  void advanceKaraokeLyric({
    required int lineNo,
    required int startMs,
    required int endMs,
    required String text,
  }) {
    _sendKaraokeWsAction({
      "action": "advance_lyric",
      "performance_id": karaokePerformanceId.value,
      "line_no": lineNo,
      "start_ms": startMs,
      "end_ms": endMs,
      "text": text,
    });
  }

  /// Complete Performance
  Future<void> completeKaraokePerformance({bool force = false}) async {
    _stopKaraokeAudio();
    _sendKaraokeWsAction({
      "action": "complete_performance",
      "performance_id": karaokePerformanceId.value,
      "force": force,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      await gameService.completeKaraokePerformance(
        karaokePerformanceId.value,
        force: force,
      );
    }
  }

  /// Singer Quits Early
  Future<void> leaveKaraokePerformance({String reason = 'SINGER_QUIT'}) async {
    _stopKaraokeAudio();
    _sendKaraokeWsAction({
      "action": "leave_performance",
      "performance_id": karaokePerformanceId.value,
      "reason": reason,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      await gameService.leaveKaraokePerformance(
        karaokePerformanceId.value,
        reason: reason,
      );
    }
  }

  /// Host Removes Singer Early
  Future<void> removeKaraokeSinger({
    String reason = 'INTERRUPTED_BY_HOST',
  }) async {
    _stopKaraokeAudio();
    _sendKaraokeWsAction({
      "action": "remove_singer",
      "performance_id": karaokePerformanceId.value,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      await gameService.removeKaraokeSinger(
        karaokePerformanceId.value,
        reason: reason,
      );
    }
  }

  /// Send Fan Gift (Source a)
  Future<void> sendKaraokeGift({
    required int receiverUserId,
    required double amount,
    String giftType = 'KARAOKE_MIC',
  }) async {
    _sendKaraokeWsAction({
      "action": "send_gift",
      "receiver_user_id": receiverUserId,
      "amount": amount,
      "gift_type": giftType,
    });
    if (karaokeGameId.value.isNotEmpty) {
      await gameService.sendKaraokeGift(
        karaokeGameId.value,
        receiverUserId: receiverUserId,
        amount: amount,
        giftType: giftType,
      );
    }
  }

  /// Host Ends Game Session
  Future<void> endKaraokeGame({String reason = 'HOST_ENDED'}) async {
    _stopKaraokeAudio();
    _sendKaraokeWsAction({"action": "end_game", "reason": reason});
    if (karaokeGameId.value.isNotEmpty) {
      await gameService.endKaraokeGame(karaokeGameId.value, reason: reason);
    }
  }

  Timer? _karaokeLyricSyncTimer;

  String _resolveKaraokeAudioUrl(String? rawUrl) {
    if (rawUrl != null &&
        rawUrl.trim().isNotEmpty &&
        !rawUrl.contains('assets.glotune.com')) {
      return rawUrl.trim();
    }
    final trackId = karaokeCurrentTrackId.value;
    for (final t in karaokeCatalog) {
      if (t['id']?.toString() == trackId || t['audio_url'] != null) {
        final catUrl = t['audio_url']?.toString();
        if (catUrl != null &&
            catUrl.isNotEmpty &&
            !catUrl.contains('assets.glotune.com')) {
          return catUrl;
        }
      }
    }
    return rawUrl?.trim() ?? "";
  }

  Future<void> _playKaraokeAudio(String? url) async {
    try {
      await _stopKaraokeAudio();
      final targetUrl = _resolveKaraokeAudioUrl(url);
      if (targetUrl.isEmpty) return;
      print("[LiveKaraoke Audio Host] Initializing and playing: $targetUrl");
      final player = vp.VideoPlayerController.networkUrl(Uri.parse(targetUrl));
      _karaokeAudioPlayer = player;
      await player.initialize();
      await player.setVolume(1.0);
      await player.play();
      print("[LiveKaraoke Audio Host] Audio playback started!");

      // Start Real-time Lyrics Synchronization Timer
      _karaokeLyricSyncTimer?.cancel();
      _karaokeLyricSyncTimer = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) {
          if (_karaokeAudioPlayer == null ||
              !_karaokeAudioPlayer!.value.isInitialized)
            return;
          final posMs = _karaokeAudioPlayer!.value.position.inMilliseconds;
          _updateLyricsAtPosition(posMs);
        },
      );
    } catch (e) {
      print("[LiveKaraoke Audio Host] Error playing karaoke track: $e");
    }
  }

  void _updateLyricsAtPosition(int posMs) {
    if (karaokeLyricsList.isEmpty) return;

    int activeIdx = -1;
    for (int i = 0; i < karaokeLyricsList.length; i++) {
      final seg = karaokeLyricsList[i];
      final start = seg['start_ms'] is int
          ? seg['start_ms'] as int
          : (int.tryParse(seg['start_ms']?.toString() ?? '') ?? 0);
      final end = seg['end_ms'] is int
          ? seg['end_ms'] as int
          : (int.tryParse(seg['end_ms']?.toString() ?? '') ?? 9999999);
      if (posMs >= start && posMs < end) {
        activeIdx = i;
        break;
      }
    }

    if (activeIdx == -1) {
      final firstStart = karaokeLyricsList.first['start_ms'] is int
          ? karaokeLyricsList.first['start_ms'] as int
          : 0;
      if (posMs < firstStart) {
        karaokeCurrentLyricText.value = "🎵 [Music Intro]";
        karaokeNextLyricText.value =
            karaokeLyricsList.first['text']?.toString() ?? '';
        return;
      }
      final lastEnd = karaokeLyricsList.last['end_ms'] is int
          ? karaokeLyricsList.last['end_ms'] as int
          : 0;
      if (posMs >= lastEnd) {
        karaokeCurrentLyricText.value = "🎵 [Outro]";
        karaokeNextLyricText.value = "";
        return;
      }
      for (int i = 0; i < karaokeLyricsList.length - 1; i++) {
        final curEnd = karaokeLyricsList[i]['end_ms'] is int
            ? karaokeLyricsList[i]['end_ms'] as int
            : 0;
        final nextStart = karaokeLyricsList[i + 1]['start_ms'] is int
            ? karaokeLyricsList[i + 1]['start_ms'] as int
            : 0;
        if (posMs >= curEnd && posMs < nextStart) {
          karaokeCurrentLyricText.value = "🎵 [Instrumental Break]";
          karaokeNextLyricText.value =
              karaokeLyricsList[i + 1]['text']?.toString() ?? '';
          return;
        }
      }
    } else {
      final currentSeg = karaokeLyricsList[activeIdx];
      final currentLine = currentSeg['text']?.toString() ?? '';
      final nextLine = (activeIdx + 1 < karaokeLyricsList.length)
          ? (karaokeLyricsList[activeIdx + 1]['text']?.toString() ?? '')
          : '';

      if (karaokeCurrentLyricText.value != currentLine) {
        karaokeCurrentLyricText.value = currentLine;
        karaokeCurrentLyricLine.value =
            currentSeg['line_no'] ?? (activeIdx + 1);
        karaokeNextLyricText.value = nextLine;

        advanceKaraokeLyric(
          lineNo: karaokeCurrentLyricLine.value,
          startMs: currentSeg['start_ms'] ?? 0,
          endMs: currentSeg['end_ms'] ?? 0,
          text: currentLine,
        );
      }
    }
  }

  Future<void> _stopKaraokeAudio() async {
    _karaokeLyricSyncTimer?.cancel();
    _karaokeLyricSyncTimer = null;

    try {
      if (_karaokeAudioPlayer != null) {
        print("[LiveKaraoke Audio Host] Stopping audio player");
        await _karaokeAudioPlayer!.pause();
        await _karaokeAudioPlayer!.dispose();
        _karaokeAudioPlayer = null;
      }
    } catch (e) {
      print("[LiveKaraoke Audio Host] Error stopping audio player: $e");
      _karaokeAudioPlayer = null;
    }
  }

  void _showKaraokeEndSummaryDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: const Color(0xFF1E293B),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🏆 Karaoke Session Complete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "Total Fan Gifts: ${karaokeTotalFanGifts.value}",
                style: const TextStyle(color: Colors.cyanAccent),
              ),
              Text(
                "Platform Rewards Released: ${karaokeTotalReleasedRewards.value}",
                style: const TextStyle(color: Colors.greenAccent),
              ),
              Text(
                "Host Share (10%): ${karaokeHostShareEarnings.value}",
                style: const TextStyle(color: Colors.amberAccent),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text("Awesome!"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateTo(String step) {
    if (step != "LiveKaraoke") {
      _stopKaraokeAudio();
    }
    currentStep.value = step;
    if (step == "LiveBoxBattle") {
      joinSession("box battle");
    } else if (step == "LiveBattle1v1") {
      joinSession("1v1");
    } else if (step == "LiveBattle2v2") {
      joinSession("2v2");
    } else if (step == "LiveQuiz") {
      joinSession("quiz");
    } else if (step == "LiveKaraoke") {
      joinSession("karaoke");
    } else if (step == "LiveStream") {
      joinSession("live");
    }
  }

  Future<void> pickMediaFromGallery() async {
    // Reset thumbnail on new media pick
    selectedThumbnailPath.value = "";
    if (selectedTab.value == "Posts") {
      final XFile? media = await _picker.pickMedia();
      if (media != null) {
        selectedMediaPath.value = media.path;
        final lowerPath = media.path.toLowerCase();
        final isVideo =
            lowerPath.endsWith('.mp4') ||
            lowerPath.endsWith('.mov') ||
            lowerPath.endsWith('.avi') ||
            lowerPath.endsWith('.mkv');

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

  // ==================== 1V1 BATTLE INTEGRATIONS ====================

  LiveGameService get gameService => Get.find<LiveGameService>();

  /// Start Find Host Matchmaking
  Future<void> startFindHostMatchmaking() async {
    if (isMatchmaking.value) return;
    isMatchmaking.value = true;
    matchmakingDurationSeconds.value = 0;

    _matchmakingTimer?.cancel();
    _matchmakingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      matchmakingDurationSeconds.value++;
    });

    final res = await gameService.joinMatchmaking(gameType: '1v1');
    print("[DEBUG 1v1] joinMatchmaking res: $res");

    // Start periodic status poll
    _matchmakingHeartbeatTimer?.cancel();
    _matchmakingHeartbeatTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      if (!isMatchmaking.value) {
        timer.cancel();
        return;
      }
      final statusRes = await gameService.getMatchmakingStatus();
      print("[DEBUG 1v1] statusRes: $statusRes");
      if (statusRes != null &&
          (statusRes['status'] == 'matched' || statusRes['match_id'] != null)) {
        timer.cancel();
        _matchmakingTimer?.cancel();
        isMatchmaking.value = false;

        final matchId =
            statusRes['match_id']?.toString() ??
            statusRes['id']?.toString() ??
            '';
        final opp = statusRes['opponent'] ?? statusRes['matched_user'];
        if (opp is Map) {
          opponentName.value =
              opp['username'] ?? opp['full_name'] ?? 'Challenger';
          opponentAvatar.value = opp['profile_picture'] ?? '';
          opponentUserId.value = opp['id'];
        }
        if (matchId.isNotEmpty) {
          startBattleSession(matchId);
        }
      }
    });
  }

  /// Cancel Find Host Matchmaking
  Future<void> cancelFindHostMatchmaking() async {
    isMatchmaking.value = false;
    _matchmakingTimer?.cancel();
    _matchmakingHeartbeatTimer?.cancel();
    matchmakingDurationSeconds.value = 0;
    await gameService.cancelMatchmaking();
  }

  /// Challenge or invite a user to 1v1 battle
  Future<void> inviteUserToBattle(
    int userId,
    String userName, {
    String? userAvatar,
  }) async {
    opponentName.value = userName;
    if (userAvatar != null && userAvatar.isNotEmpty) {
      opponentAvatar.value = userAvatar;
    }
    opponentUserId.value = userId;

    if (liveRoomId.value.isNotEmpty) {
      await gameService.inviteToLiveRoom(
        liveRoomId.value,
        userId,
        role: 'co_host',
      );
    }
    if (activeLobbyId.value.isNotEmpty) {
      await gameService.inviteToLobby(activeLobbyId.value, userId);
    }

    Get.snackbar(
      "Battle Challenge Sent",
      "Invited $userName to 1v1 Battle!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
  }

  /// Start 1v1 Battle session
  void startBattleSession(String matchId) {
    activeMatchId.value = matchId;
    isBattleActive.value = true;
    isBattleEnded.value = false;
    battleTimerSeconds.value = 180;
    battleTimerText.value = '03:00';

    gameService.startMatch(matchId);

    _battleCountdownTimer?.cancel();
    _battleCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (battleTimerSeconds.value > 0) {
        battleTimerSeconds.value--;
        final m = (battleTimerSeconds.value ~/ 60).toString().padLeft(2, '0');
        final s = (battleTimerSeconds.value % 60).toString().padLeft(2, '0');
        battleTimerText.value = "$m:$s";
      } else {
        timer.cancel();
        endBattleMatch();
      }
    });

    _battleScorePollTimer?.cancel();
    _battleScorePollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isBattleActive.value) {
        timer.cancel();
        return;
      }
      fetchBattleScores();
    });
  }

  /// Fetch authoritative scores from match API
  Future<void> fetchBattleScores() async {
    if (activeMatchId.value.isEmpty) return;
    final res = await gameService.getMatchScores(activeMatchId.value);
    if (res != null) {
      if (res['host_score'] != null) {
        hostBattleScore.value =
            int.tryParse(res['host_score'].toString()) ?? hostBattleScore.value;
      }
      if (res['opponent_score'] != null) {
        opponentBattleScore.value =
            int.tryParse(res['opponent_score'].toString()) ??
            opponentBattleScore.value;
      }
    }
  }

  /// Tap / Cheer score submission
  Future<void> sendBattleScore(int points, {String action = 'point'}) async {
    hostBattleScore.value += points;
    if (activeMatchId.value.isNotEmpty) {
      await gameService.submitScore(
        activeMatchId.value,
        scoreDelta: points,
        action: action,
      );
    }
  }

  /// Send official gift
  Future<void> sendBattleGift({
    required String giftType,
    int quantity = 1,
    bool toOpponent = false,
  }) async {
    final Map<String, int> coinCosts = {
      'heart': 5,
      'rose': 10,
      'galaxy': 25,
      'diamond': 50,
      'crown': 100,
    };
    final costPerUnit = coinCosts[giftType.toLowerCase()] ?? 10;
    final totalCoins = costPerUnit * quantity;
    final scorePoints = totalCoins * 10;

    if (toOpponent) {
      opponentBattleScore.value += scorePoints;
    } else {
      hostBattleScore.value += scorePoints;
    }

    _reactionStreamController.add(giftType);

    if (activeMatchId.value.isNotEmpty) {
      await gameService.sendMatchGift(
        activeMatchId.value,
        giftType: giftType,
        quantity: quantity,
        recipientId: toOpponent ? opponentUserId.value : null,
      );
    } else if (liveRoomId.value.isNotEmpty) {
      await gameService.sendLiveRoomGift(
        liveRoomId.value,
        giftType: giftType,
        quantity: quantity,
      );
    }

    Get.snackbar(
      "Gift Sent! 🎉",
      "Sent $quantity x ${giftType.toUpperCase()} ($totalCoins coins) +$scorePoints pts!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
  }

  /// Quit / surrender battle
  Future<void> quitBattleMatch() async {
    if (activeMatchId.value.isNotEmpty) {
      await gameService.quitMatch(activeMatchId.value);
    }
    _battleCountdownTimer?.cancel();
    _battleScorePollTimer?.cancel();
    _matchmakingTimer?.cancel();
    _matchmakingHeartbeatTimer?.cancel();
    isMatchmaking.value = false;
    isBattleActive.value = false;
    activeMatchId.value = '';
    opponentUserId.value = null;
    opponentName.value = 'Challenger 🥊';
    opponentAvatar.value = '';

    navigateTo("LiveStream");
    Get.snackbar(
      "Battle Ended",
      "You left the 1v1 battle session.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
  }

  void endBattleMatch() {
    isBattleActive.value = false;
    isBattleEnded.value = true;
    _battleCountdownTimer?.cancel();
    _battleScorePollTimer?.cancel();

    if (hostBattleScore.value > opponentBattleScore.value) {
      battleWinner.value = 'host';
    } else if (opponentBattleScore.value > hostBattleScore.value) {
      battleWinner.value = 'opponent';
    } else {
      battleWinner.value = 'draw';
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                battleWinner.value == 'host'
                    ? "🏆 VICTORY!"
                    : (battleWinner.value == 'opponent'
                          ? "DEFEAT 🥊"
                          : "🤝 DRAW!"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Host: ${hostBattleScore.value} pts vs Opponent: ${opponentBattleScore.value} pts",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5252A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
