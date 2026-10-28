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
import 'package:glotune/app/data/models/user_profile.dart';
import 'package:glotune/app/core/constants/gift_catalogue.dart';
import 'package:glotune/app/data/models/gift_item_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart' as vp;

class LivePlayerController extends GetxController {
  late final String roomId;
  late RtcEngine engine;

  final userProfile = Rxn<UserProfile>();

  final isLoading = true.obs;
  final isEngineInitialized = false.obs;

  // State for rendering remote users
  final remoteUids = <int>[].obs;

  // Host and Co-host broadcaster state
  final isHost = false.obs;
  final hostId = 0.obs;
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
  String _roomAgoraToken = '';

  final liveMessages = [].obs;
  final liveMembers = <dynamic>[].obs;
  String? _pendingSessionJoin;

  // Dynamic live streaming type from streamer ("live", "box battle", "1v1", "2v2", "quiz", "karaoke")
  final currentLiveType = 'live'.obs;

  // Box Battle state
  final boxSlots = <Map<String, dynamic>>[].obs;
  final myBoxSlotNumber = 0.obs;
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
  final karaokeTitle = "".obs;
  final karaokeArtist = "".obs;
  final karaokeContentType = "INSTRUMENTAL".obs;
  final karaokeLyrics = "".obs;
  final karaokeCurrentSinger = "".obs;
  final karaokeCurrentSingerId = 0.obs;
  final karaokePerformanceId = "".obs;
  final karaokeGameId = "".obs;
  final karaokeGameStatus = "WAITING_FOR_SINGER".obs;
  final isKaraokePerformanceActive = false.obs;
  final karaokeTimerText = "00:00".obs;
  final karaokeTimerSeconds = 0.obs;
  final isRewardEligible = false.obs;
  final karaokeNextLyric = ''.obs;
  final karaokeLyricsList = <Map<String, dynamic>>[].obs;
  final karaokeParticipants = <Map<String, dynamic>>[].obs;
  final karaokeCatalog = <Map<String, dynamic>>[].obs;
  final selectedKaraokeCategory = 'INSTRUMENTAL'.obs; // Default to INSTRUMENTAL
  final isKaraokeCatalogLoading = false.obs;

  bool get isSingerAssignedToMe {
    try {
      final auth = Get.find<AuthService>();
      final myUid = auth.currentUserId.value;
      return myUid != null && myUid > 0 && myUid == karaokeCurrentSingerId.value;
    } catch (_) {
      return false;
    }
  }

  final karaokeAudioUrl = ''.obs;
  vp.VideoPlayerController? _karaokeAudioPlayer;
  String? _currentPlayingAudioUrl;
  WebSocket? _karaokeWs;
  Timer? _karaokeTimer;
  Timer? _karaokeLyricSyncTimer;

  void initBoxBattleSlots() {
    if (boxSlots.isNotEmpty) return;
    for (int i = 1; i <= 8; i++) {
      boxSlots.add({
        'slot_number': i,
        'status': 'VACANT',
        'uid': null,
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

  void assignGuestToVacantSlot(int uid, {String? username, String? profilePic}) {
    initBoxBattleSlots();
    final existingIndex = boxSlots.indexWhere((s) {
      final sUid = s['uid'] ?? s['user_id'] ?? s['guest_id'];
      return sUid != null && sUid.toString() == uid.toString();
    });
    if (existingIndex != -1) return;

    final vacantIndex = boxSlots.indexWhere((s) => s['status'] == 'VACANT');
    if (vacantIndex != -1) {
      final slotNum = boxSlots[vacantIndex]['slot_number'];
      final updated = Map<String, dynamic>.from(boxSlots[vacantIndex]);
      updated['status'] = 'OCCUPIED';
      updated['uid'] = uid;
      updated['user_id'] = uid;
      updated['guest_id'] = uid;
      updated['username'] = username ?? 'Guest $slotNum';
      if (profilePic != null) updated['profile_picture'] = profilePic;
      updated['gift_total'] = 100;
      updated['bonus_total'] = 10;
      updated['mic_on'] = true;
      updated['camera_on'] = true;
      boxSlots[vacantIndex] = updated;
    }
  }

  void _freeSlotByUid(int uid) {
    final index = boxSlots.indexWhere((s) {
      final sUid = s['uid'] ?? s['user_id'] ?? s['guest_id'];
      return sUid != null && sUid.toString() == uid.toString();
    });
    if (index != -1) {
      final slotNum = boxSlots[index]['slot_number'];
      boxSlots[index] = {
        'slot_number': slotNum,
        'status': 'VACANT',
        'uid': null,
        'user_id': null,
        'guest_id': null,
        'username': null,
        'profile_picture': null,
        'gift_total': 0,
        'bonus_total': 0,
        'mic_on': true,
        'camera_on': true,
      };
      if (myBoxSlotNumber.value == slotNum) {
        myBoxSlotNumber.value = 0;
      }
    }
  }

  Future<void> joinBoxSlot(int slotNumber) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    final myId = authService.currentUserId.value;

    if (token == null) {
      Get.snackbar(
        'Login Required',
        'Please log in to join the box.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // 1. Upgrade Agora to Broadcaster if currently an audience member
      if (!isCohost.value && !isHost.value) {
        await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await engine.enableVideo();
        await engine.enableAudio();
        await engine.startPreview();
        await engine.updateChannelMediaOptions(
          const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
          ),
        );
        isCohost.value = true;
      }

      // 2. Mark slot as occupied by me
      initBoxBattleSlots();
      final slotIdx = boxSlots.indexWhere((s) => s['slot_number'] == slotNumber);
      if (slotIdx != -1) {
        final updated = Map<String, dynamic>.from(boxSlots[slotIdx]);
        updated['status'] = 'OCCUPIED';
        updated['uid'] = localUid.value != 0 ? localUid.value : (myId ?? 0);
        updated['user_id'] = myId;
        updated['guest_id'] = myId;
        updated['username'] = 'You (Box $slotNumber)';
        updated['mic_on'] = !isMicMuted.value;
        updated['camera_on'] = !isCamOff.value;
        boxSlots[slotIdx] = updated;
      }
      myBoxSlotNumber.value = slotNumber;

      // 3. Broadcast to all users via WebSocket
      if (_chatWs != null) {
        _chatWs!.add(
          jsonEncode({
            "type": "box_slot_update",
            "action": "box_slot_update",
            "slot_number": slotNumber,
            "status": "OCCUPIED",
            "uid": localUid.value != 0 ? localUid.value : myId,
            "user_id": myId,
            "username": "Guest $slotNumber",
            "room_id": roomId,
          }),
        );
      }

      Get.snackbar(
        "Joined Box $slotNumber",
        "You are now live in Box $slotNumber!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print("Error joining box slot: $e");
      Get.snackbar("Error", "Could not join box slot: $e");
    }
  }

  Future<void> leaveBoxSlot(int slotNumber) async {
    try {
      initBoxBattleSlots();
      final slotIdx = boxSlots.indexWhere((s) => s['slot_number'] == slotNumber);
      if (slotIdx != -1) {
        boxSlots[slotIdx] = {
          'slot_number': slotNumber,
          'status': 'VACANT',
          'uid': null,
          'user_id': null,
          'guest_id': null,
          'username': null,
          'profile_picture': null,
          'gift_total': 0,
          'bonus_total': 0,
          'mic_on': true,
          'camera_on': true,
        };
      }
      myBoxSlotNumber.value = 0;

      // Downgrade client role to audience if not host
      if (!isHost.value) {
        await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
        await engine.updateChannelMediaOptions(
          const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleAudience,
            publishCameraTrack: false,
            publishMicrophoneTrack: false,
          ),
        );
        isCohost.value = false;
      }

      if (_chatWs != null) {
        _chatWs!.add(
          jsonEncode({
            "type": "box_slot_update",
            "action": "box_slot_update",
            "slot_number": slotNumber,
            "status": "VACANT",
            "room_id": roomId,
          }),
        );
      }

      Get.snackbar(
        "Left Box",
        "You vacated Box $slotNumber.",
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error leaving box slot: $e");
    }
  }

  void sendGiftToBox(int slotNumber) {
    initBoxBattleSlots();
    final slotIdx = boxSlots.indexWhere((s) => s['slot_number'] == slotNumber);
    if (slotIdx != -1) {
      final updated = Map<String, dynamic>.from(boxSlots[slotIdx]);
      updated['gift_total'] = (updated['gift_total'] ?? 0) + 100;
      boxSlots[slotIdx] = updated;
      battleScoreGuest.value += 100;
      showTemporaryNotice("Sent gift to Box $slotNumber! +100 Score");
    }
    sendReaction('🎁');
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
      } else if (newType == 'karaoke') {
        _connectKaraokeWebSocket();
      } else {
        _stopKaraokeAudio();
        if (_quizWs != null) {
          try {
            _quizWs!.close();
          } catch (_) {}
          _quizWs = null;
        }
        if (_karaokeWs != null) {
          try {
            _karaokeWs!.close();
          } catch (_) {}
          _karaokeWs = null;
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

  // ==================== LIVE KARAOKE WEBSOCKET ENGINE (VIEWER) ====================

  void _connectKaraokeWebSocket() {
    if (_karaokeWs != null) {
      try {
        _karaokeWs!.close();
      } catch (_) {}
      _karaokeWs = null;
    }

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';

      final wsUrl =
          '$wsScheme://${parsed.host}$portStr/ws/live/$roomId/karaoke/?token=${token ?? ''}';
      print("[LivePlayer Karaoke WS] Connecting: $wsUrl");

      WebSocket.connect(wsUrl).then((ws) {
        _karaokeWs = ws;
        print("[LivePlayer Karaoke WS] Connected successfully!");

        // Request authoritative state
        _sendKaraokeWsAction({'action': 'get_state'});
        fetchKaraokeCatalog();

        ws.listen((event) {
          try {
            final data = jsonDecode(event.toString());
            print("[LivePlayer Karaoke WS Event]: $data");
            if (data is Map<String, dynamic>) {
              _handleKaraokeWsEvent(data);
            }
          } catch (e) {
            print("[LivePlayer Karaoke WS] Parse error: $e");
          }
        }, onError: (err) {
          print("[LivePlayer Karaoke WS] Stream error: $err");
          _karaokeWs = null;
        }, onDone: () {
          print("[LivePlayer Karaoke WS] Stream closed");
          _karaokeWs = null;
        });
      }).catchError((err) {
        print("[LivePlayer Karaoke WS] Connect error: $err");
      });
    } catch (e) {
      print("[LivePlayer Karaoke WS] Exception connecting: $e");
    }
  }

  void _sendKaraokeWsAction(Map<String, dynamic> payload) {
    try {
      if (_karaokeWs != null) {
        _karaokeWs!.add(jsonEncode(payload));
        print("[LivePlayer Karaoke WS] Sent action: $payload");
      }
    } catch (e) {
      print("[LivePlayer Karaoke WS] Send error: $e");
    }
  }

  void _handleKaraokeWsEvent(Map<String, dynamic> data) {
    final event = data['event']?.toString() ?? data['type']?.toString();
    final Map<String, dynamic> payload = data['payload'] is Map
        ? Map<String, dynamic>.from(data['payload'])
        : data;

    print("[LivePlayer Karaoke WS] Processing event: $event");

    switch (event) {
      case 'connection_ack':
      case 'CONNECTED':
        if (data['game_id'] != null) {
          karaokeGameId.value = data['game_id'].toString();
        }
        if (data['state'] is Map) {
          final state = Map<String, dynamic>.from(data['state']);
          karaokeGameStatus.value = state['status']?.toString() ?? 'WAITING_FOR_SINGER';
          if (state['participants'] is List) {
            karaokeParticipants.value = List<Map<String, dynamic>>.from(state['participants']);
          }
          if (state['active_performance'] is Map) {
            final perf = Map<String, dynamic>.from(state['active_performance']);
            karaokePerformanceId.value = perf['id']?.toString() ?? '';
            karaokeCurrentSinger.value = perf['performer_username']?.toString() ?? '';
            karaokeCurrentSingerId.value = perf['performer_id'] is int ? perf['performer_id'] : (int.tryParse(perf['performer_id']?.toString() ?? '') ?? 0);
            karaokeTitle.value = perf['track_title']?.toString() ?? karaokeTitle.value;
            karaokeArtist.value = perf['track_artist']?.toString() ?? '';
            karaokeContentType.value = perf['content_type']?.toString() ?? 'INSTRUMENTAL';
            isRewardEligible.value = perf['is_reward_eligible'] == true;
          }
        }
        break;

      case 'SINGER_ASSIGNED':
        karaokePerformanceId.value = payload['performance_id']?.toString() ?? '';
        karaokeCurrentSinger.value = payload['performer_username']?.toString() ?? 'Guest';
        karaokeCurrentSingerId.value = payload['performer_id'] is int ? payload['performer_id'] : (int.tryParse(payload['performer_id']?.toString() ?? '') ?? 0);
        karaokeGameStatus.value = 'SINGER_ASSIGNED';

        final authService = Get.find<AuthService>();
        final myUid = authService.currentUserId.value;
        if (myUid != null && myUid == karaokeCurrentSingerId.value) {
          showTemporaryNotice("🎤 You are the assigned singer! Select a track to perform!");
        } else {
          showTemporaryNotice("🎤 @${karaokeCurrentSinger.value} is assigned to sing!");
        }
        break;

      case 'TRACK_SELECTED':
        karaokeTitle.value = payload['title']?.toString() ?? '';
        karaokeArtist.value = payload['artist']?.toString() ?? '';
        karaokeContentType.value = payload['type']?.toString() ?? 'INSTRUMENTAL';
        isRewardEligible.value = payload['is_reward_eligible'] == true;
        karaokeGameStatus.value = 'TRACK_SELECTED';
        showTemporaryNotice("🎵 Track: ${karaokeTitle.value} (${karaokeContentType.value})");
        break;

      case 'PLAYBACK_PREPARED':
        karaokeAudioUrl.value = payload['audio_url']?.toString() ?? '';
        final extractedPrep = _extractLyricSegments(payload);
        if (extractedPrep.isNotEmpty) {
          karaokeLyricsList.value = extractedPrep;
          karaokeLyrics.value = "🎵 Ready to sing";
          karaokeNextLyric.value = extractedPrep.first['text']?.toString() ?? '';
        }
        karaokeGameStatus.value = 'PLAYBACK_PREPARED';
        break;

      case 'PERFORMANCE_STARTED':
        isKaraokePerformanceActive.value = true;
        karaokeGameStatus.value = 'PERFORMANCE_ACTIVE';
        final durMs = payload['duration_ms'] ?? 180000;
        final durSec = (durMs is int && durMs > 0) ? (durMs ~/ 1000) : 180;
        _startKaraokeCountdownTimer(durSec);
        final playUrl = payload['audio_url']?.toString() ?? karaokeAudioUrl.value;
        if (playUrl.isNotEmpty) karaokeAudioUrl.value = playUrl;
        final extractedStart = _extractLyricSegments(payload);
        if (extractedStart.isNotEmpty) {
          karaokeLyricsList.value = extractedStart;
        }
        _playKaraokeAudio(karaokeAudioUrl.value);
        break;

      case 'LYRIC_LINE_CHANGED':
        karaokeLyrics.value = payload['text']?.toString() ?? '';
        if (payload['line_no'] != null && karaokeLyricsList.isNotEmpty) {
          final lineNo = int.tryParse(payload['line_no'].toString()) ?? 1;
          if (lineNo >= 0 && lineNo < karaokeLyricsList.length) {
            karaokeNextLyric.value = karaokeLyricsList[lineNo]['text']?.toString() ?? '';
          }
        }
        break;

      case 'PERFORMANCE_COMPLETED':
        isKaraokePerformanceActive.value = false;
        _karaokeTimer?.cancel();
        _stopKaraokeAudio();
        karaokeGameStatus.value = 'COMPLETED';
        showTemporaryNotice("🌟 Performance Completed!");
        break;

      case 'REWARD_PENDING':
        showTemporaryNotice("Held reward: ${payload['amount']} coins on hold (1000 fan threshold)");
        break;

      case 'REWARD_RELEASED':
        showTemporaryNotice("💰 Reward Released! Fan threshold satisfied.");
        break;

      case 'REWARD_FORFEITED':
        showTemporaryNotice("⚠️ Reward Forfeited: Fan gifts under 1000 threshold.");
        break;

      case 'GIFT_SENT':
        final recId = payload['receiver_user_id'] ?? payload['recipient_id'];
        final amt = double.tryParse(payload['amount']?.toString() ?? '0') ?? 0;
        final idx = karaokeParticipants.indexWhere((p) => p['user_id'] == recId);
        if (idx != -1) {
          final curA = double.tryParse(karaokeParticipants[idx]['fan_gifts_a']?.toString() ?? '0') ?? 0;
          karaokeParticipants[idx]['fan_gifts_a'] = (curA + amt).toStringAsFixed(2);
          karaokeParticipants.refresh();
        }
        break;

      case 'GAME_ENDED':
        isKaraokePerformanceActive.value = false;
        _karaokeTimer?.cancel();
        _stopKaraokeAudio();
        karaokeGameStatus.value = 'ENDED';
        showTemporaryNotice("🏆 Karaoke Session Ended");
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
        karaokeTimerText.value = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      } else {
        karaokeTimerSeconds.value = 0;
        karaokeTimerText.value = '00:00';
        isKaraokePerformanceActive.value = false;
        t.cancel();
      }
    });
  }

  void setKaraokeCategory(String category) {
    selectedKaraokeCategory.value = category;
    fetchKaraokeCatalog(type: category);
  }

  Future<void> fetchKaraokeCatalog({String? type, String? query}) async {
    isKaraokeCatalogLoading.value = true;
    final catType = type ?? selectedKaraokeCategory.value;
    final rId = roomId.isNotEmpty ? roomId : 'a81f7ca6-16f9-42fe-9be0-03c47700d7df';
    try {
      final gameService = Get.find<LiveGameService>();
      var list = await gameService.getKaraokeCatalog(rId, type: catType, q: query);
      if (list.isEmpty && rId != 'a81f7ca6-16f9-42fe-9be0-03c47700d7df') {
        list = await gameService.getKaraokeCatalog('a81f7ca6-16f9-42fe-9be0-03c47700d7df', type: catType, q: query);
      }
      if (list.isEmpty && (query == null || query.isEmpty)) {
        list = await gameService.getKaraokeCatalog(rId);
        if (list.isEmpty && rId != 'a81f7ca6-16f9-42fe-9be0-03c47700d7df') {
          list = await gameService.getKaraokeCatalog('a81f7ca6-16f9-42fe-9be0-03c47700d7df');
        }
      }

      karaokeCatalog.value = list;
    } catch (_) {
      karaokeCatalog.value = [];
    } finally {
      isKaraokeCatalogLoading.value = false;
    }
  }

  Future<void> selectKaraokeTrack(String trackId, String contentType) async {
    Map<String, dynamic>? selected;
    for (final t in karaokeCatalog) {
      if (t['id']?.toString() == trackId) {
        selected = t;
        break;
      }
    }
    if (selected != null) {
      karaokeTitle.value = selected['title']?.toString() ?? '';
      karaokeArtist.value = selected['artist']?.toString() ?? '';
      karaokeContentType.value = contentType;
      if (selected['audio_url'] != null) {
        karaokeAudioUrl.value = selected['audio_url'].toString();
      }
      final extracted = _extractLyricSegments(selected);
      if (extracted.isNotEmpty) {
        karaokeLyricsList.value = extracted;
        karaokeLyrics.value = "🎵 Ready: ${selected['title']}";
        karaokeNextLyric.value = extracted.first['text']?.toString() ?? '';
      }
    }

    _sendKaraokeWsAction({
      "action": "select_track",
      "performance_id": karaokePerformanceId.value,
      "track_id": trackId,
      "content_type": contentType,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      try {
        final gameService = Get.find<LiveGameService>();
        await gameService.selectKaraokeTrack(
          karaokePerformanceId.value,
          trackId: trackId,
          contentType: contentType,
        );
      } catch (_) {}
    }
  }

  Future<void> prepareKaraokePlayback() async {
    _sendKaraokeWsAction({
      "action": "prepare_playback",
      "performance_id": karaokePerformanceId.value,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      try {
        final gameService = Get.find<LiveGameService>();
        await gameService.prepareKaraokePlayback(karaokePerformanceId.value);
      } catch (_) {}
    }
  }

  Future<void> startKaraokePerformance() async {
    isKaraokePerformanceActive.value = true;
    karaokeGameStatus.value = 'PERFORMANCE_ACTIVE';
    final durSec = 200;
    _startKaraokeCountdownTimer(durSec);
    if (karaokeAudioUrl.value.isNotEmpty) {
      _playKaraokeAudio(karaokeAudioUrl.value);
    }

    _sendKaraokeWsAction({
      "action": "start_performance",
      "performance_id": karaokePerformanceId.value,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      try {
        final gameService = Get.find<LiveGameService>();
        await gameService.startKaraokePerformance(karaokePerformanceId.value);
      } catch (_) {}
    }
  }

  void sendKaraokeGift({
    required int receiverUserId,
    required double amount,
    String giftType = 'KARAOKE_MIC',
  }) {
    _sendKaraokeWsAction({
      "action": "send_gift",
      "receiver_user_id": receiverUserId,
      "amount": amount,
      "gift_type": giftType,
    });
  }

  Future<void> leaveKaraokePerformance({String reason = 'SINGER_QUIT'}) async {
    _stopKaraokeAudio();
    _sendKaraokeWsAction({
      "action": "leave_performance",
      "performance_id": karaokePerformanceId.value,
      "reason": reason,
    });
    if (karaokePerformanceId.value.isNotEmpty) {
      try {
        final gameService = Get.find<LiveGameService>();
        await gameService.leaveKaraokePerformance(
          karaokePerformanceId.value,
          reason: reason,
        );
      } catch (_) {}
    }
  }

  List<Map<String, dynamic>> _extractLyricSegments(Map<String, dynamic> track) {
    if (track['lyric_segments'] is List && (track['lyric_segments'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(track['lyric_segments']);
    }
    final lrc = track['lrc']?.toString();
    if (lrc != null && lrc.trim().isNotEmpty) {
      final parsed = _parseLrc(lrc);
      if (parsed.isNotEmpty) return parsed;
    }
    final lyricsStr = track['lyrics']?.toString();
    if (lyricsStr != null && lyricsStr.trim().isNotEmpty) {
      final lines = lyricsStr.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final durMs = (track['duration_ms'] is num) ? (track['duration_ms'] as num).toInt() : 200000;
      final stepMs = lines.isNotEmpty ? (durMs ~/ lines.length) : 5000;
      return List.generate(lines.length, (i) => {
        'line_no': i + 1,
        'start_ms': i * stepMs,
        'end_ms': (i + 1) * stepMs,
        'text': lines[i].trim(),
      });
    }
    return [];
  }

  List<Map<String, dynamic>> _parseLrc(String lrcText) {
    final List<Map<String, dynamic>> segments = [];
    final lines = lrcText.split('\n');
    final regExp = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{2,3})?\](.*)');
    int lineNo = 1;
    for (int i = 0; i < lines.length; i++) {
      final match = regExp.firstMatch(lines[i]);
      if (match != null) {
        final min = int.tryParse(match.group(1) ?? '0') ?? 0;
        final sec = int.tryParse(match.group(2) ?? '0') ?? 0;
        final msStr = match.group(3) ?? '0';
        final ms = int.tryParse(msStr.padRight(3, '0').substring(0, 3)) ?? 0;
        final startMs = (min * 60 + sec) * 1000 + ms;
        final text = (match.group(4) ?? '').trim();
        if (text.isNotEmpty) {
          segments.add({
            'line_no': lineNo++,
            'start_ms': startMs,
            'end_ms': startMs + 4000,
            'text': text,
          });
        }
      }
    }
    for (int i = 0; i < segments.length - 1; i++) {
      segments[i]['end_ms'] = segments[i + 1]['start_ms'];
    }
    return segments;
  }

  String _resolveKaraokeAudioUrl(String? rawUrl) {
    if (rawUrl != null &&
        rawUrl.trim().isNotEmpty &&
        !rawUrl.contains('assets.glotune.com')) {
      return rawUrl.trim();
    }
    final title = karaokeTitle.value;
    for (final t in karaokeCatalog) {
      if (t['title']?.toString() == title || t['audio_url'] != null) {
        final catUrl = t['audio_url']?.toString();
        if (catUrl != null && catUrl.isNotEmpty && !catUrl.contains('assets.glotune.com')) {
          return catUrl;
        }
      }
    }
    return rawUrl?.trim() ?? "";
  }

  Future<void> _playKaraokeAudio(String? url) async {
    final targetUrl = _resolveKaraokeAudioUrl(url);
    if (targetUrl.isEmpty) return;

    // GUARD: If already playing or loading this track, don't restart or stop!
    if (_currentPlayingAudioUrl == targetUrl && _karaokeAudioPlayer != null) {
      print("[LiveKaraoke Audio Viewer] Audio is already playing/initializing: $targetUrl, skipping duplicate start");
      return;
    }

    try {
      await _stopKaraokeAudio();
      _currentPlayingAudioUrl = targetUrl;
      print("[LiveKaraoke Audio Viewer] Initializing and playing: $targetUrl");

      final auth = Get.find<AuthService>();
      final token = auth.accessToken.value;
      final headers = <String, String>{
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final player = vp.VideoPlayerController.networkUrl(
        Uri.parse(targetUrl),
        httpHeaders: headers,
      );
      _karaokeAudioPlayer = player;
      await player.initialize();
      await player.setVolume(1.0);
      await player.setLooping(false);
      await player.play();
      print("[LiveKaraoke Audio Viewer] Audio playback started!");

      player.addListener(() {
        if (player.value.hasError) {
          print("[LiveKaraoke Audio Viewer] Player error: ${player.value.errorDescription}");
        }
        if (player.value.isInitialized &&
            player.value.duration > const Duration(seconds: 30) &&
            player.value.position >= player.value.duration) {
          print("[LiveKaraoke Audio Viewer] Song ended naturally");
          _stopKaraokeAudio();
        }
      });

      // Ensure lyrics list is populated
      if (karaokeLyricsList.isEmpty) {
        for (final t in karaokeCatalog) {
          final segs = _extractLyricSegments(t);
          if (segs.isNotEmpty) {
            karaokeLyricsList.value = segs;
            break;
          }
        }
      }

      _karaokeLyricSyncTimer?.cancel();
      _karaokeLyricSyncTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (_karaokeAudioPlayer == null || !_karaokeAudioPlayer!.value.isInitialized) return;
        final posMs = _karaokeAudioPlayer!.value.position.inMilliseconds;
        _updateLyricsAtPosition(posMs);
      });
    } catch (e) {
      print("[LiveKaraoke Audio Viewer] Error playing karaoke audio: $e");
    }
  }

  void _updateLyricsAtPosition(int posMs) {
    if (karaokeLyricsList.isEmpty) {
      for (final t in karaokeCatalog) {
        final segs = _extractLyricSegments(t);
        if (segs.isNotEmpty) {
          karaokeLyricsList.value = segs;
          break;
        }
      }
      if (karaokeLyricsList.isEmpty) return;
    }

    int activeIdx = -1;
    for (int i = 0; i < karaokeLyricsList.length; i++) {
      final seg = karaokeLyricsList[i];
      final start = (seg['start_ms'] is num)
          ? (seg['start_ms'] as num).toInt()
          : (int.tryParse(seg['start_ms']?.toString() ?? '') ?? 0);
      final end = (seg['end_ms'] is num)
          ? (seg['end_ms'] as num).toInt()
          : (int.tryParse(seg['end_ms']?.toString() ?? '') ?? 9999999);
      if (posMs >= start && posMs < end) {
        activeIdx = i;
        break;
      }
    }

    if (activeIdx == -1) {
      final firstSeg = karaokeLyricsList.first;
      final firstStart = (firstSeg['start_ms'] is num)
          ? (firstSeg['start_ms'] as num).toInt()
          : (int.tryParse(firstSeg['start_ms']?.toString() ?? '') ?? 0);
      if (posMs < firstStart) {
        karaokeLyrics.value = "🎵 [Music Intro]";
        karaokeNextLyric.value = firstSeg['text']?.toString() ?? '';
        return;
      }
      final lastSeg = karaokeLyricsList.last;
      final lastEnd = (lastSeg['end_ms'] is num)
          ? (lastSeg['end_ms'] as num).toInt()
          : (int.tryParse(lastSeg['end_ms']?.toString() ?? '') ?? 0);
      if (posMs >= lastEnd) {
        karaokeLyrics.value = "🎵 [Outro]";
        karaokeNextLyric.value = "";
        return;
      }
      for (int i = 0; i < karaokeLyricsList.length - 1; i++) {
        final curEnd = (karaokeLyricsList[i]['end_ms'] is num)
            ? (karaokeLyricsList[i]['end_ms'] as num).toInt()
            : 0;
        final nextStart = (karaokeLyricsList[i + 1]['start_ms'] is num)
            ? (karaokeLyricsList[i + 1]['start_ms'] as num).toInt()
            : 0;
        if (posMs >= curEnd && posMs < nextStart) {
          karaokeLyrics.value = "🎵 [Instrumental Break]";
          karaokeNextLyric.value = karaokeLyricsList[i + 1]['text']?.toString() ?? '';
          return;
        }
      }
    } else {
      final currentSeg = karaokeLyricsList[activeIdx];
      final currentLine = currentSeg['text']?.toString() ?? '';
      final nextLine = (activeIdx + 1 < karaokeLyricsList.length)
          ? (karaokeLyricsList[activeIdx + 1]['text']?.toString() ?? '')
          : '';

      karaokeLyrics.value = currentLine;
      karaokeNextLyric.value = nextLine;
    }
  }

  Future<void> _stopKaraokeAudio() async {
    _karaokeLyricSyncTimer?.cancel();
    _karaokeLyricSyncTimer = null;
    _currentPlayingAudioUrl = null;
    try {
      if (_karaokeAudioPlayer != null) {
        print("[LiveKaraoke Audio Viewer] Stopping audio player");
        await _karaokeAudioPlayer!.pause();
        await _karaokeAudioPlayer!.dispose();
        _karaokeAudioPlayer = null;
      }
    } catch (e) {
      print("[LiveKaraoke Audio Viewer] Error stopping audio player: $e");
      _karaokeAudioPlayer = null;
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
    fetchUserProfile();
    _initAgora();
  }

  Future<void> fetchUserProfile() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) {
        print("[DEBUG LivePlayer] fetchUserProfile: Token is NULL!");
        return;
      }

      print("[DEBUG LivePlayer] GET ${ApiConstants.baseUrl}auth/profile/me/ ...");
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}auth/profile/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("[DEBUG LivePlayer] fetchUserProfile response: ${response.statusCode} | body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          userProfile.value = UserProfile.fromJson(data);
          print("[DEBUG LivePlayer] UserProfile loaded: ${userProfile.value?.fullName} | yourCoins: ${userProfile.value?.yourCoins}");
        }
      } else {
        print("[DEBUG LivePlayer] Failed to load profile: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("[DEBUG LivePlayer] Error fetching user profile: $e");
    }
  }

  Future<void> _initAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    try {
      // 1. Fetch room details
      await _fetchRoomDetails();

      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      // Call join room endpoint on backend only for viewers (host gets 403 Host cannot join as viewer)
      if (!isHost.value) {
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
      }

      // 2. Fetch Agora Token and App ID
      String agoraToken = '';
      String agoraAppId = '';
      int agoraUid = 0;

      try {
        final tokenResponse = await apiClient.get(
          Uri.parse('${ApiConstants.baseUrl}live/token/$roomId/'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        );

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
        }
      } catch (e) {
        print("Warning: Failed to fetch Agora token: $e");
      }

      if (agoraToken.isEmpty && _roomAgoraToken.isNotEmpty) {
        agoraToken = _roomAgoraToken;
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

      final clientRole = isHost.value
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience;

      await engine.setClientRole(role: clientRole);
      await engine.enableVideo();
      await engine.enableAudio();

      if (isHost.value) {
        await engine.startPreview();
      }

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
            if (currentLiveType.value == 'box battle') {
              assignGuestToVacantSlot(remoteUid);
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
                if (currentLiveType.value == 'box battle') {
                  _freeSlotByUid(remoteUid);
                }
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
        uid: agoraUid,
        options: ChannelMediaOptions(
          clientRoleType: clientRole,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: isHost.value,
          publishMicrophoneTrack: isHost.value,
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

    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        title.value = data['title'] ?? "Live Stream";
        memberCount.value = data['viewer_count'] ?? data['member_count'] ?? 0;
        final hostObj = data['host'];
        if (hostObj is Map<String, dynamic>) {
          hostProfilePic.value = hostObj['profile_picture'] ?? '';
          hostId.value = (hostObj['id'] is int
                  ? hostObj['id'] as int
                  : int.tryParse(hostObj['id']?.toString() ?? '')) ??
              0;
        } else if (data['host_id'] != null) {
          hostId.value = int.tryParse(data['host_id'].toString()) ?? 0;
        }

        final myId = authService.currentUserId.value;
        if (data['is_host'] == true ||
            (myId != null && hostId.value != 0 && myId == hostId.value)) {
          isHost.value = true;
          print("[LivePlayer] Current user is identified as HOST of this room");
        }

        if (data['agora_token'] != null &&
            data['agora_token'].toString().isNotEmpty) {
          _roomAgoraToken = data['agora_token'].toString();
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
        title.value = "Live Stream";
      }
    } catch (e) {
      print("Warning: Exception in _fetchRoomDetails: $e");
      title.value = "Live Stream";
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
    final event = data['event']?.toString();

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
    // 3a. Personal Gift Sent Acknowledgment from Server
    else if (type == 'gift_sent' || event == 'gift_sent' || action == 'gift_sent') {
      final dynamic rawSentData = data['data'];
      final Map<String, dynamic> giftData = (rawSentData is Map<String, dynamic>)
          ? rawSentData
          : data;
      final remaining = giftData['remaining_coins'];
      if (remaining != null && userProfile.value != null) {
        final parsed = int.tryParse(remaining.toString());
        if (parsed != null) {
          userProfile.value = userProfile.value!.copyWith(yourCoins: parsed);
          print("[LivePlayer WS] Updated user balance to $parsed coins");
        }
      }
    }
    // 3b. Room Broadcast Gift Received (Trigger Animation & Chat Banner)
    else if (type == 'gift_received' ||
        event == 'gift_received' ||
        action == 'gift_received' ||
        type == 'gift') {
      final dynamic rawRecvData = data['data'];
      final Map<String, dynamic> giftData = (rawRecvData is Map<String, dynamic>)
          ? rawRecvData
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

      print("[LivePlayer WS] Incoming gift received: $giftIdentifier x$quantity from $senderName");
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
    // 8. Box Battle slot updates
    else if (type == 'box_slot_update' ||
        action == 'box_slot_update' ||
        type == 'box_slot_join' ||
        type == 'box_slot_leave') {
      final slotNumber = data['slot_number'];
      final status = data['status']?.toString() ??
          (type == 'box_slot_leave' ? 'VACANT' : 'OCCUPIED');
      if (slotNumber != null) {
        final slotNum = int.tryParse(slotNumber.toString());
        if (slotNum != null && slotNum >= 1 && slotNum <= 8) {
          initBoxBattleSlots();
          final idx = boxSlots.indexWhere((s) => s['slot_number'] == slotNum);
          if (idx != -1) {
            if (status == 'VACANT') {
              boxSlots[idx] = {
                'slot_number': slotNum,
                'status': 'VACANT',
                'uid': null,
                'user_id': null,
                'guest_id': null,
                'username': null,
                'profile_picture': null,
                'gift_total': 0,
                'bonus_total': 0,
                'mic_on': true,
                'camera_on': true,
              };
              if (myBoxSlotNumber.value == slotNum) {
                myBoxSlotNumber.value = 0;
              }
            } else {
              final s = Map<String, dynamic>.from(boxSlots[idx]);
              s['status'] = 'OCCUPIED';
              s['uid'] = data['uid'] ?? data['user_id'];
              s['user_id'] = data['user_id'];
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
    } else if (type == 'guest_gift_update' || action == 'guest_gift_update') {
      final slotNumber = data['slot_number'];
      final giftTotal = data['gift_total'];
      final bonusTotal = data['bonus_total'];
      if (slotNumber != null) {
        final slotNum = int.tryParse(slotNumber.toString());
        if (slotNum != null) {
          final idx = boxSlots.indexWhere((s) => s['slot_number'] == slotNum);
          if (idx != -1) {
            final s = Map<String, dynamic>.from(boxSlots[idx]);
            if (giftTotal != null) s['gift_total'] = giftTotal;
            if (bonusTotal != null) s['bonus_total'] = bonusTotal;
            boxSlots[idx] = s;
          }
        }
      }
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
    _stopKaraokeAudio();
    _karaokeTimer?.cancel();
    try {
      _karaokeWs?.close();
    } catch (_) {}
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

  Future<void> sendGift(
    dynamic giftOrName, {
    int quantity = 1,
    int coins = 0,
    int? recipientId,
  }) async {
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

    // Resolve gift details from GiftItem or canonical code/name lookup
    String giftCode = '';
    String giftName = 'Gift';
    int unitCoins = coins;

    if (giftOrName is GiftItem) {
      giftCode = giftOrName.code;
      giftName = giftOrName.name;
      unitCoins = giftOrName.coins;
    } else if (giftOrName is String) {
      final found = GiftCatalogue.find(giftOrName);
      if (found != null) {
        giftCode = found.code;
        giftName = found.name;
        unitCoins = found.coins;
      } else {
        giftName = giftOrName;
        if (giftOrName.toUpperCase().startsWith('GT')) {
          giftCode = giftOrName.toUpperCase();
        }
      }
    }

    final totalCoins = unitCoins * quantity;
    final senderId = userProfile.value?.id;
    final resolvedRecipientId = recipientId ?? (hostId.value > 0 ? hostId.value : null);

    print("[DEBUG SEND GIFT] userProfile: ${userProfile.value?.fullName} (id: $senderId)");
    print("[DEBUG SEND GIFT] yourCoins locally: ${userProfile.value?.yourCoins}");
    print("[DEBUG SEND GIFT] giftCode: '$giftCode', giftName: '$giftName', unitCoins: $unitCoins, qty: $quantity, totalCoins: $totalCoins");
    print("[DEBUG SEND GIFT] resolvedRecipientId: $resolvedRecipientId (hostId: ${hostId.value})");

    if (userProfile.value == null || userProfile.value!.yourCoins == 0) {
      print("[DEBUG SEND GIFT] yourCoins is 0 or null locally, refreshing from /auth/profile/me/ ...");
      await fetchUserProfile();
      print("[DEBUG SEND GIFT] After refresh -> yourCoins: ${userProfile.value?.yourCoins}");
    }

    final currentCoins = userProfile.value?.yourCoins ?? 0;
    print("[DEBUG SEND GIFT] Balance check: currentCoins=$currentCoins, required totalCoins=$totalCoins");

    // Only block on client if user definitely has a recorded balance that is less than totalCoins
    if (currentCoins > 0 && currentCoins < totalCoins) {
      print("[DEBUG SEND GIFT] Insufficient balance: $currentCoins < $totalCoins");
      Get.snackbar(
        'Insufficient Coins',
        'You have $currentCoins coins, but this gift requires $totalCoins coins.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (currentCoins == 0) {
      print("[DEBUG SEND GIFT] Notice: Local balance is 0. Sending to backend WebSocket for authoritative atomic balance verification.");
    }

    // 1. Authoritative WebSocket Send (with atomic deduction & room broadcast)
    if (_chatWs != null) {
      try {
        final wsPayload = {
          "event": "send_gift",
          "action": "send_gift",
          "data": {
            "gift_code": giftCode,
            "gift_name": giftName,
            "coins": unitCoins,
            "quantity": quantity,
            "total_coins": totalCoins,
            if (senderId != null) "sender_id": senderId,
            if (resolvedRecipientId != null) "recipient_id": resolvedRecipientId,
            "room_id": roomId,
          },
          // flat fields for backward compatibility
          "gift_code": giftCode,
          "gift_name": giftName,
          "gift_type": giftName,
          "coins": unitCoins,
          "quantity": quantity,
          "total_coins": totalCoins,
          if (senderId != null) "sender_id": senderId,
          if (resolvedRecipientId != null) "recipient_id": resolvedRecipientId,
          "room_id": roomId,
        };

        _chatWs!.add(jsonEncode(wsPayload));
        print("[LivePlayer WS] Sent gift via WebSocket: $wsPayload");

        // Optimistically deduct coins locally
        if (userProfile.value != null && totalCoins > 0) {
          final current = userProfile.value!.yourCoins;
          final updated = current - totalCoins;
          userProfile.value = userProfile.value!.copyWith(
            yourCoins: updated > 0 ? updated : 0,
          );
        }

        // Local reaction animation trigger
        _reactionStreamController.add(giftCode.isNotEmpty ? giftCode : giftName);

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        Get.snackbar(
          'Gift Sent! 🎁',
          'Sent $quantity $giftName successfully!',
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
        return;
      } catch (wsErr) {
        print("[LivePlayer WS] Error sending gift via WebSocket: $wsErr, falling back to REST");
      }
    }

    // 2. Fallback REST API
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/send-gift/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'gift_code': giftCode,
          'gift_type': giftName,
          'quantity': quantity,
          if (resolvedRecipientId != null) 'recipient_id': resolvedRecipientId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (userProfile.value != null && totalCoins > 0) {
          final current = userProfile.value!.yourCoins;
          final updated = current - totalCoins;
          userProfile.value = userProfile.value!.copyWith(
            yourCoins: updated > 0 ? updated : 0,
          );
        }

        _reactionStreamController.add(giftCode.isNotEmpty ? giftCode : giftName);

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        Get.snackbar(
          'Gift Sent! 🎁',
          'Sent $quantity $giftName successfully!',
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            final msg = errorBody['detail'] ?? errorBody['error'] ?? 'Failed to send gift: ${response.statusCode}';
            Get.snackbar(
              'Error',
              msg.toString(),
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
