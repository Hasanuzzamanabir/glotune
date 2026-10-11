import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:glotune/app/core/services/live_game_service.dart';
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
  final liveMembers = <dynamic>[].obs;
  String? _pendingSessionJoin;

  // Dynamic live streaming type from streamer ("live", "box battle", "1v1", "2v2", "quiz", "karaoke")
  final currentLiveType = 'live'.obs;

  // Box Battle state
  final boxSlots = <Map<String, dynamic>>[].obs;
  final boxBattleTimerSeconds = 90.obs;
  final battleScoreHost = 100.obs;
  final battleScoreGuest = 100.obs;

  final quizQuestion = <String, dynamic>{
    'category': 'Entertainment and Pop Culture',
    'question':
        'Which pop star released the record-breaking album "Midnights"?',
    'options': ['Taylor Swift', 'Dua Lipa', 'Beyonce', 'Billie Eilish'],
    'correct_option': 'Taylor Swift',
  }.obs;
  final quizCategories = <Map<String, dynamic>>[].obs;
  final selectedQuizCategoryId = ''.obs;
  final selectedQuizCategoryName = ''.obs;
  final activeQuizAnswers = <Map<String, dynamic>>[].obs;
  final isQuizRoundActive = false.obs;
  final quizTimerText = '00:30'.obs;
  final quizSelectedOption = Rxn<String>();
  final quizTimeLeft = 30.obs;
  final quizRoundId = ''.obs;
  final quizRoundNo = 1.obs;
  final isQuizAnswerSubmitted = false.obs;
  final isQuizScored = false.obs;
  final quizCorrectOption = ''.obs;
  final quizFirstWinner = ''.obs;
  final quizParticipants = <Map<String, dynamic>>[].obs;
  WebSocket? _quizWs;
  Timer? _quizTimer;

  // Karaoke state
  final karaokeTitle = "Acoustic Pop Jam".obs;
  final karaokeLyrics =
      "Sing along with the live host... 🎵\nCause we are golden hours under neon lights"
          .obs;

  void initBoxBattleSlots() {
    if (boxSlots.isNotEmpty) return;
    for (int i = 1; i <= 8; i++) {
      boxSlots.add({
        'slot_number': i,
        'status': 'VACANT',
        'user_id': null,
        'guest_id': null,
        'username': null,
        'profile_picture': null,
        'gift_total': 0,
        'bonus_total': 0,
        'mic_on': true,
        'camera_on': true,
      });
    }
  }

  void updateLiveType(dynamic rawType) {
    if (rawType == null) return;
    final str = rawType.toString().toLowerCase().trim();
    String newType = 'live';
    if (str.contains('box')) {
      newType = 'box battle';
    } else if (str.contains('1v1')) {
      newType = '1v1';
    } else if (str.contains('2v2')) {
      newType = '2v2';
    } else if (str.contains('quiz')) {
      newType = 'quiz';
    } else if (str.contains('karaoke')) {
      newType = 'karaoke';
    } else {
      newType = 'live';
    }

    if (currentLiveType.value != newType) {
      currentLiveType.value = newType;
      print("[LivePlayer WS] Streamer switched live type to: $newType");
      showTemporaryNotice("Stream switched to ${newType.toUpperCase()}");

      if (newType == 'box battle') {
        initBoxBattleSlots();
      } else if (newType == 'quiz') {
        _connectQuizWebSocket();
      } else {
        if (_quizWs != null) {
          try {
            _quizWs!.close();
          } catch (_) {}
          _quizWs = null;
        }
      }

      // Auto join this session so viewer is registered on socket
      joinSession(newType);
    }
  }

  // ==================== LIVE QUIZ WEBSOCKET ENGINE (VIEWER) ====================

  void _connectQuizWebSocket() {
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

      final wsUrl =
          '$wsScheme://${parsed.host}$portStr/ws/live/$roomId/quiz/?token=${token ?? ''}';
      print("[LivePlayer Quiz WS] Connecting to Quiz WebSocket: $wsUrl");

      WebSocket.connect(wsUrl)
          .then((ws) {
            _quizWs = ws;
            print("[LivePlayer Quiz WS] Connected successfully!");
            fetchQuizCategories();

            // Auto join game as GUEST
            _sendQuizWsAction({
              'action': 'join_game',
              'seat': '1',
              'role': 'GUEST',
            });

            ws.listen(
              (event) {
                try {
                  final data = jsonDecode(event.toString());
                  print("[LivePlayer Quiz WS Event]: $data");
                  if (data is Map<String, dynamic>) {
                    _handleQuizWsEvent(data);
                  }
                } catch (e) {
                  print("[LivePlayer Quiz WS] Parse error: $e");
                }
              },
              onError: (err) {
                print("[LivePlayer Quiz WS] Stream error: $err");
                _quizWs = null;
              },
              onDone: () {
                print("[LivePlayer Quiz WS] Stream closed");
                _quizWs = null;
              },
            );
          })
          .catchError((err) {
            print("[LivePlayer Quiz WS] Connect error: $err");
          });
    } catch (e) {
      print("[LivePlayer Quiz WS] Exception connecting: $e");
    }
  }

  void _sendQuizWsAction(Map<String, dynamic> payload) {
    try {
      if (_quizWs != null) {
        _quizWs!.add(jsonEncode(payload));
        print("[LivePlayer Quiz WS] Sent action: $payload");
      }
    } catch (e) {
      print("[LivePlayer Quiz WS] Send error: $e");
    }
  }

  Future<void> fetchQuizCategories() async {
    final rId = roomId.isNotEmpty
        ? roomId
        : 'cf50c1d8-0a2e-4dd8-8cc9-a5916a0bb62d';
    try {
      final gameService = Get.find<LiveGameService>();
      final cats = await gameService.getQuizCategories(rId);
      if (cats.isNotEmpty) {
        quizCategories.value = cats;
        if (selectedQuizCategoryId.value.isEmpty) {
          selectedQuizCategoryId.value = cats.first['id'].toString();
          selectedQuizCategoryName.value = cats.first['name'].toString();
        }
      }
    } catch (e) {
      print("[LivePlayer Quiz WS] fetchQuizCategories error: $e");
    }
  }

  void _startQuizTimer(int seconds) {
    _quizTimer?.cancel();
    quizTimeLeft.value = seconds;
    isQuizRoundActive.value = seconds > 0;
    quizTimerText.value = '00:${seconds.toString().padLeft(2, '0')}';

    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (quizTimeLeft.value > 1) {
        quizTimeLeft.value--;
        quizTimerText.value =
            '00:${quizTimeLeft.value.toString().padLeft(2, '0')}';
      } else {
        quizTimeLeft.value = 0;
        quizTimerText.value = '00:00';
        isQuizRoundActive.value = false;
        timer.cancel();
      }
    });
  }

  void _handleQuizWsEvent(Map<String, dynamic> data) {
    final event = data['event']?.toString() ?? data['type']?.toString();
    final Map<String, dynamic> payload = data['payload'] is Map
        ? Map<String, dynamic>.from(data['payload'])
        : data;

    print("[LivePlayer Quiz WS] Received event: $event");

    switch (event) {
      case 'connection_ack':
      case 'CONNECTED':
        if (data['state'] is Map) {
          final state = Map<String, dynamic>.from(data['state']);
          if (state['active_round'] is Map) {
            final round = state['active_round'];
            quizRoundId.value =
                (round['id'] ?? round['round_id'])?.toString() ?? '';
            quizRoundNo.value = round['round_no'] ?? 1;
            if (round['question'] is Map) {
              final q = round['question'];
              quizQuestion['question'] = q['question_text']?.toString() ?? '';
              if (q['answers'] is List) {
                activeQuizAnswers.value = List<Map<String, dynamic>>.from(
                  q['answers'],
                );
                quizQuestion['options'] = (q['answers'] as List).map((a) {
                  return "${a['option_code']}. ${a['answer_text']}";
                }).toList();
              }
            }
            final duration = round['duration_sec'] ?? 30;
            _startQuizTimer(duration is int ? duration : 30);
          }
          if (state['active_category'] is Map) {
            final catName =
                state['active_category']['name']?.toString() ??
                'General Knowledge';
            selectedQuizCategoryName.value = catName;
            quizQuestion['category'] = catName;
          }
          if (state['participants'] is List) {
            quizParticipants.value = List<Map<String, dynamic>>.from(
              state['participants'],
            );
          }
        }
        _sendQuizWsAction({
          'action': 'join_game',
          'seat': '1',
          'role': 'GUEST',
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
        if (payload['category_name'] != null) {
          selectedQuizCategoryName.value = payload['category_name'].toString();
          quizQuestion['category'] = payload['category_name'].toString();
          quizQuestion.refresh();
        }
        if (payload['category_id'] != null) {
          selectedQuizCategoryId.value = payload['category_id'].toString();
        }
        break;

      case 'ROUND_STARTED':
        quizRoundId.value =
            (payload['round_id'] ?? data['round_id'])?.toString() ?? '';
        quizRoundNo.value = payload['round_no'] ?? 1;
        quizSelectedOption.value = null;
        isQuizAnswerSubmitted.value = false;
        isQuizScored.value = false;
        quizCorrectOption.value = '';
        quizFirstWinner.value = '';
        isQuizRoundActive.value = true;
        if (payload['category_name'] != null) {
          selectedQuizCategoryName.value = payload['category_name'].toString();
          quizQuestion['category'] = payload['category_name'].toString();
        }
        final duration = payload['duration_sec'] ?? 30;
        _startQuizTimer(duration is int ? duration : 30);
        break;

      case 'QUESTION_ACTIVE':
        if (payload['round_id'] != null) {
          quizRoundId.value = payload['round_id'].toString();
        }
        if (payload['round_no'] != null) {
          quizRoundNo.value = payload['round_no'] is int
              ? payload['round_no']
              : int.tryParse(payload['round_no'].toString()) ?? 1;
        }
        if (payload['question'] is Map) {
          final q = Map<String, dynamic>.from(payload['question']);
          quizQuestion['question'] = q['question_text']?.toString() ?? '';
          if (q['answers'] is List) {
            activeQuizAnswers.value = List<Map<String, dynamic>>.from(
              q['answers'],
            );
            quizQuestion['options'] = (q['answers'] as List).map((a) {
              return "${a['option_code']}. ${a['answer_text']}";
            }).toList();
          }
        }
        if (payload['category_name'] != null) {
          selectedQuizCategoryName.value = payload['category_name'].toString();
          quizQuestion['category'] = payload['category_name'].toString();
        }
        quizQuestion.refresh();
        quizSelectedOption.value = null;
        isQuizAnswerSubmitted.value = false;
        isQuizScored.value = false;
        quizCorrectOption.value = '';
        quizFirstWinner.value = '';
        isQuizRoundActive.value = true;
        _startQuizTimer(30);
        break;

      case 'ANSWER_SELECTED':
        final authService = Get.find<AuthService>();
        final myUid = authService.currentUserId.value;
        final uid = payload['user_id'];
        if (myUid != null &&
            uid != null &&
            myUid.toString() == uid.toString()) {
          quizSelectedOption.value = payload['option_code']?.toString();
          isQuizAnswerSubmitted.value = true;
        }
        // Update participant in grid
        if (uid != null) {
          final pIdx = quizParticipants.indexWhere((p) => p['user_id'] == uid);
          if (pIdx != -1) {
            quizParticipants[pIdx]['selected_option'] = payload['option_code'];
            quizParticipants.refresh();
          }
        }
        break;

      case 'ROUND_RESULT':
        isQuizScored.value = true;
        isQuizRoundActive.value = false;
        _quizTimer?.cancel();
        quizCorrectOption.value = payload['correct_option']?.toString() ?? '';
        quizFirstWinner.value =
            payload['first_correct_username']?.toString() ?? '';
        showTemporaryNotice(
          "Round result: Correct is ${quizCorrectOption.value} 🏆",
        );
        break;

      case 'ROUND_ENDED':
        isQuizRoundActive.value = false;
        _quizTimer?.cancel();
        break;

      case 'GAME_ENDED':
        isQuizRoundActive.value = false;
        _quizTimer?.cancel();
        showTemporaryNotice("Quiz Session Ended 🏆");
        break;
    }
  }

  void lockQuizCategory(String categoryId, String categoryName) {
    selectedQuizCategoryId.value = categoryId;
    selectedQuizCategoryName.value = categoryName;
    quizQuestion['category'] = categoryName;
    quizQuestion.refresh();
    _sendQuizWsAction({
      "action": "lock_category",
      "category_id": categoryId,
    });
  }

  void submitQuizAnswer(String code) {
    selectQuizOption(code);
  }

  void selectQuizOption(String option) {
    if (isQuizAnswerSubmitted.value) return;

    String code = option.trim();
    if (code.contains('.')) {
      code = code.split('.').first.trim();
    } else if (code.length > 1) {
      code = code.substring(0, 1);
    }
    code = code.toUpperCase();

    quizSelectedOption.value = option;
    isQuizAnswerSubmitted.value = true;
    showTemporaryNotice("You voted: $code");

    final authService = Get.find<AuthService>();
    final userId = authService.currentUserId.value ?? 1;
    final idempotencyKey =
        'ans_user${userId}_r${quizRoundNo.value}_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Authoritative Quiz WebSocket action
    _sendQuizWsAction({
      "action": "submit_answer",
      "round_id": quizRoundId.value,
      "option_code": code,
      "idempotency_key": idempotencyKey,
    });

    // 2. Chat WS action
    if (_chatWs != null) {
      try {
        _chatWs!.add(
          jsonEncode({
            "action": "quiz_answer",
            "selected_option": code,
            "room_id": roomId,
          }),
        );
      } catch (_) {}
    }
  }

  String? _currentJoinedSession;
  DateTime? _lastJoinSessionTime;
  bool _isConnectingWs = false;

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
      print("[LivePlayer WS] Suppressing duplicate join for '$normalized'");
      return;
    }

    _currentJoinedSession = normalized;
    _lastJoinSessionTime = now;

    final payload = jsonEncode({"action": "join", "type": normalized});

    if (_chatWs != null) {
      try {
        _chatWs!.add(payload);
        print("[LivePlayer WS] Sent join session: $payload");
      } catch (e) {
        print("[LivePlayer WS] Error sending join session: $e");
      }
    } else {
      print(
        "[LivePlayer WS] Socket not yet connected, queuing join session: $normalized",
      );
      _pendingSessionJoin = normalized;
    }
  }

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
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      String agoraToken = '';
      String agoraAppId = '';
      int agoraUid = 0;

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        agoraToken = tokenData['agora_token'] ?? tokenData['token'] ?? '';
        agoraAppId =
            tokenData['agora_app_id'] ??
            tokenData['app_id'] ??
            tokenData['appId'] ??
            '';
        agoraUid =
            (tokenData['agora_uid'] is int
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
      await engine.initialize(
        RtcEngineContext(
          appId: agoraAppId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

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
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
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
      final rawType =
          data['game_type'] ??
          data['battle_type'] ??
          data['type'] ??
          data['current_game_type'];
      if (rawType != null) {
        updateLiveType(rawType);
      }
    } else {
      print("Failed to fetch room details: ${response.statusCode}");
      throw Exception("Failed to load room");
    }
  }

  void _connectInRoomWebSocket() {
    if (_chatWs != null || _isConnectingWs) {
      print("[LivePlayer WS] Already connected or connection in progress");
      return;
    }
    _isConnectingWs = true;

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';
      final primaryWsUrl =
          '$wsScheme://${parsed.host}$portStr/api/ws/live/$roomId/?token=${token ?? ''}';
      final fallbackWsUrl =
          '$wsScheme://${parsed.host}$portStr/ws/live/$roomId/?token=${token ?? ''}';

      void listenWs(WebSocket ws) {
        _isConnectingWs = false;
        if (_chatWs != null && _chatWs != ws) {
          try {
            _chatWs!.close();
          } catch (_) {}
        }
        _chatWs = ws;
        print("[LivePlayer WS] Connected successfully to: ${ws.toString()}");

        // Immediately send join session to socket
        final sessionToJoin = _pendingSessionJoin ?? 'live';
        _pendingSessionJoin = null;
        joinSession(sessionToJoin);

        ws.listen(
          (event) {
            try {
              final data = jsonDecode(event.toString());
              print("[LivePlayer WS Event]: $data");
              if (data is Map<String, dynamic>) {
                _handleWebSocketEvent(data);
              }
            } catch (err) {
              print("[LivePlayer WS] Error parsing message: $err");
            }
          },
          onError: (err) {
            print("[LivePlayer WS] Stream error: $err");
            _chatWs = null;
            _isConnectingWs = false;
            _scheduleWsReconnect();
          },
          onDone: () {
            print("[LivePlayer WS] Stream closed");
            _chatWs = null;
            _isConnectingWs = false;
            _scheduleWsReconnect();
          },
        );
      }

      print("[LivePlayer WS] Connecting to primary: $primaryWsUrl");
      WebSocket.connect(primaryWsUrl)
          .then((ws) {
            listenWs(ws);
          })
          .catchError((err) {
            print(
              "[LivePlayer WS] Primary connect error ($err), attempting fallback to: $fallbackWsUrl",
            );
            WebSocket.connect(fallbackWsUrl)
                .then((ws) {
                  listenWs(ws);
                })
                .catchError((fallbackErr) {
                  _isConnectingWs = false;
                  print("[LivePlayer WS] Fallback connect error: $fallbackErr");
                });
          });
    } catch (e) {
      _isConnectingWs = false;
      print("[LivePlayer WS] Setup exception: $e");
    }
  }

  void _handleWebSocketEvent(Map<String, dynamic> data) {
    print("[LivePlayer] Processing event: $data");
    final type = data['type']?.toString();
    final action = data['action']?.toString();

    // 0. Session status & notification event (e.g. joined box battle, quiz, 1v1, 2v2, live, karaoke)
    if (type == 'session_status' ||
        type == 'session_status_notification' ||
        action == 'join' ||
        action == 'session_status' ||
        action == 'session_status_notification') {
      _handleSessionStatusEvent(data);
      return;
    }

    // 0b. Detect battle/game start or live type changes
    if (type == 'battle_started' ||
        action == 'battle_started' ||
        type == 'game_started' ||
        action == 'game_started') {
      final bType = data['battle_type'] ?? data['game_type'] ?? 'box battle';
      updateLiveType(bType);
    } else if (type == 'battle_ended' ||
        action == 'battle_ended' ||
        type == 'game_ended' ||
        action == 'game_ended') {
      updateLiveType('live');
    } else if (type == 'change_live_type' ||
        action == 'change_live_type' ||
        type == 'live_type' ||
        action == 'live_type') {
      final lType = data['live_type'] ?? data['game_type'] ?? 'live';
      updateLiveType(lType);
    }

    // 1. Message event
    if (type == 'message' || action == 'message') {
      final text = (data['message'] ?? data['text'] ?? data['content'])
          ?.toString();
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
      final reactionName =
          (type == 'heart' ||
              action == 'heart' ||
              type == 'love' ||
              action == 'love')
          ? 'heart'
          : (data['reaction_type']?.toString() ??
                data['reaction']?.toString() ??
                'like');
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
      final countVal =
          data['viewer_count'] ?? data['member_count'] ?? data['count'];
      if (countVal != null) {
        final parsed = int.tryParse(countVal.toString());
        if (parsed != null) {
          memberCount.value = parsed;
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
        (type == 'stream_request' &&
            (action == 'invite' || action == 'invited'))) {
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
            final map = jsonDecode(
              utf8.decode(base64Url.decode(base64Url.normalize(p64))),
            );
            final idVal =
                map['user_id'] ?? map['id'] ?? map['sub'] ?? map['pk'];
            if (idVal != null) {
              myId = int.tryParse(idVal.toString());
              authService.currentUserId.value = myId;
            }
          }
        } catch (_) {}
      }

      // Check explicit target recipient
      final targetId =
          data['target_user_id'] ??
          data['invited_user_id'] ??
          data['recipient_id'] ??
          data['target_id'] ??
          data['to_user_id'] ??
          (data['invited_user'] is Map
              ? data['invited_user']['id']
              : data['invited_user']) ??
          (data['target_user'] is Map
              ? data['target_user']['id']
              : data['target_user']);

      final userIdsList = data['user_ids'];

      // If targetId is provided and myId is known, verify it is meant for this user
      if (targetId != null && myId != null) {
        if (targetId.toString() != myId.toString()) {
          print(
            "[LivePlayer] Invite is for user $targetId, my id is $myId - ignoring",
          );
          return;
        }
      } else if (userIdsList is List && myId != null) {
        final includesMe = userIdsList.any(
          (id) => id.toString() == myId.toString(),
        );
        if (!includesMe) {
          print(
            "[LivePlayer] Invite list does not include my id $myId - ignoring",
          );
          return;
        }
      }

      final hostName = data['host_username'] ?? data['username'] ?? 'Host';
      print(
        "[LivePlayer] Received co-host invitation from $hostName for current user!",
      );
      triggerCohostInvitationPrompt(hostName.toString());
    } else if ((type == 'notification' &&
            data['notification_type'] == 'live_invitation') ||
        type == 'live_invitation' ||
        data['notification_type'] == 'live_invitation') {
      final hostName =
          data['sender_name'] ??
          data['host_username'] ??
          data['username'] ??
          'Host';
      final notifRoomId = data['room_id']?.toString();
      if (notifRoomId == null || notifRoomId.isEmpty || notifRoomId == roomId) {
        print(
          "[LivePlayer] Received live_invitation notification from $hostName for room $roomId",
        );
        triggerCohostInvitationPrompt(hostName.toString());
      }
    } else if ((type == 'stream_request' || action == 'stream_request') &&
        (action == 'approved' || data['status'] == 'approved')) {
      print("[LivePlayer] Stream request approved! Auto-accepting cohost...");
      acceptCohostInvitation();
    }
  }

  void _handleSessionStatusEvent(Map<String, dynamic> data) {
    print("[LivePlayer WS] Handling session status event: $data");
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

    // 2. Show floating temporary notice
    showTemporaryNotice(displayMsg);

    // 3. Update Participant Part:
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
      if (liveMembers.length > memberCount.value) {
        memberCount.value = liveMembers.length;
      }
    }

    // 4. Update streaming view type to match session/game
    if (gameType.isNotEmpty && gameType != 'session') {
      updateLiveType(gameType);
    }

    // 5. Update Box Battle guest slots if game_type is box battle
    final normalizedGameType = gameType.toLowerCase().trim();
    if (normalizedGameType.contains('box')) {
      initBoxBattleSlots();
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
                style: const TextStyle(color: Colors.white70, fontSize: 13),
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
          Uri.parse(
            '${ApiConstants.baseUrl}live/rooms/$roomId/start-cohost-stream/',
          ),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        print(
          "[LivePlayer] start-cohost-stream response: ${startRes.statusCode} - ${startRes.body}",
        );
      } catch (e) {
        print("[LivePlayer] Warning calling start-cohost-stream: $e");
      }

      // 2. Fetch new Agora token with publisher role
      final tokenRes = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}live/token/$roomId/'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      String pubToken = '';
      int pubUid = localUid.value;
      if (tokenRes.statusCode == 200) {
        final tokenData = jsonDecode(tokenRes.body);
        pubToken = tokenData['agora_token'] ?? tokenData['token'] ?? '';
        final parsedUid =
            (tokenData['agora_uid'] is int
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

      final url = Uri.parse(
        '${ApiConstants.baseUrl}live/rooms/$roomId/messages/',
      );
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
        final payload = jsonEncode({"action": "message", "message": text});
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
        _chatWs!.add(jsonEncode({"action": "typing", "is_typing": isTyping}));
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
        final actionToSend = (reactionType == 'heart' || reactionType == 'love')
            ? 'heart'
            : reactionType;
        _chatWs!.add(
          jsonEncode({"action": actionToSend, "reaction_type": reactionType}),
        );
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
        body: jsonEncode({'reaction_type': reactionType}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Reaction '$reactionType' sent successfully");
      } else {
        print(
          "Failed to send reaction: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Error sending reaction: $e");
    }
  }

  Future<void> requestCohost() => requestToStream();

  Future<void> requestToStream() async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;

    if (token == null) {
      Get.snackbar(
        'Login Required',
        'Please log in to request to stream.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // 1. Send immediate real-time notification to host over WebSocket
      if (_chatWs != null) {
        final myId = authService.currentUserId.value;
        _chatWs!.add(
          jsonEncode({
            "type": "stream_request",
            "action": "requested",
            "room_id": roomId,
            "requester_id": myId,
            "user_id": myId,
          }),
        );
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
        Get.snackbar(
          'Request Sent',
          'Your request to join the stream was sent to the host!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Request to stream failed: ${res.statusCode} - ${res.body}");
        Get.snackbar(
          'Request Sent',
          'Your request was sent to the host.',
          backgroundColor: Colors.indigoAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error sending request to stream: $e");
    }
  }

  void shareLive() {
    try {
      if (_chatWs != null) {
        _chatWs!.add(jsonEncode({"action": "share"}));
      }
    } catch (e) {
      print("[LivePlayer WS] Error sending share action: $e");
    }
    Share.share(
      'Join my live stream on Glotune! https://glotune.com/live/$roomId',
    );
  }

  Future<void> sendGift(String giftType, {int quantity = 1}) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;

    if (token == null) {
      Get.snackbar(
        'Error',
        'Please login to send gifts',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/send-gift/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'gift_type': giftType, 'quantity': quantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Broadcast gift action over WebSocket to all participants
        try {
          if (_chatWs != null) {
            _chatWs!.add(
              jsonEncode({
                "action": "gift",
                "gift_type": giftType,
                "quantity": quantity,
              }),
            );
          }
        } catch (wsErr) {
          print("[LivePlayer WS] Error broadcasting gift: $wsErr");
        }

        Get.back(); // close bottom sheet
        Get.snackbar(
          'Success',
          'Gift sent successfully!',
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            if (errorBody.containsKey('detail')) {
              Get.snackbar(
                'Error',
                errorBody['detail'].toString(),
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            } else if (errorBody.containsKey('error')) {
              Get.snackbar(
                'Error',
                errorBody['error'].toString(),
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar(
                'Error',
                'Failed to send gift: ${response.statusCode}',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              'Error',
              'Failed to send gift: ${response.statusCode}',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (_) {
          Get.snackbar(
            'Error',
            'Failed to send gift: ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print("Error sending gift: $e");
      Get.snackbar(
        'Error',
        'An error occurred while sending gift',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
