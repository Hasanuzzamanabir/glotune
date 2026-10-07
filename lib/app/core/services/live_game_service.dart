import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/core/values/api_constants.dart';

class LiveGameService extends GetxService {
  String? get _token {
    try {
      final auth = Get.find<AuthService>();
      return auth.accessToken.value;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> get _headers {
    final token = _token;
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ==================== MATCHMAKING ====================

  /// Join matchmaking queue for 1v1 battle
  Future<Map<String, dynamic>?> joinMatchmaking({String gameType = '1v1'}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatchmakingJoin}');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({'game_type': gameType}),
      );
      if (kDebugMode) {
        print("[LiveGameService] joinMatchmaking [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] joinMatchmaking error: $e");
    }
    return null;
  }

  /// Check status of current matchmaking queue
  Future<Map<String, dynamic>?> getMatchmakingStatus() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatchmakingStatus}');
      final response = await apiClient.get(url, headers: _headers);
      if (kDebugMode) {
        print("[LiveGameService] getMatchmakingStatus [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getMatchmakingStatus error: $e");
    }
    return null;
  }

  /// Cancel current matchmaking queue
  Future<bool> cancelMatchmaking() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatchmakingCancel}');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] cancelMatchmaking [${response.statusCode}]");
      }
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] cancelMatchmaking error: $e");
      return false;
    }
  }

  /// Send matchmaking heartbeat to keep active in queue
  Future<bool> sendMatchmakingHeartbeat() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatchmakingHeartbeat}');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] heartbeat error: $e");
      return false;
    }
  }

  // ==================== LOBBIES ====================

  /// Create a game lobby
  Future<Map<String, dynamic>?> createLobby({Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesLobbies}');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode(data ?? {'type': '1v1'}),
      );
      if (kDebugMode) {
        print("[LiveGameService] createLobby [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] createLobby error: $e");
    }
    return null;
  }

  /// Invite an opponent to a lobby
  Future<bool> inviteToLobby(String lobbyId, int userId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesLobbies}$lobbyId/invite/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );
      if (kDebugMode) {
        print("[LiveGameService] inviteToLobby [${response.statusCode}]: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] inviteToLobby error: $e");
      return false;
    }
  }

  /// Set ready status in a lobby
  Future<bool> setLobbyReady(String lobbyId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesLobbies}$lobbyId/ready/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] setLobbyReady error: $e");
      return false;
    }
  }

  /// Leave a lobby
  Future<bool> leaveLobby(String lobbyId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesLobbies}$lobbyId/leave/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] leaveLobby error: $e");
      return false;
    }
  }

  // ==================== MATCHES ====================

  /// Get details of a match (scores, participants, status)
  Future<Map<String, dynamic>?> getMatchDetails(String matchId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/');
      final response = await apiClient.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getMatchDetails error: $e");
    }
    return null;
  }

  /// Start a match (transitions from COUNTDOWN to LIVE)
  Future<bool> startMatch(String matchId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/start/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] startMatch [${response.statusCode}]: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] startMatch error: $e");
      return false;
    }
  }

  /// Fetch live authoritative scores
  Future<Map<String, dynamic>?> getMatchScores(String matchId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/scores/');
      final response = await apiClient.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getMatchScores error: $e");
    }
    return null;
  }

  /// Submit score event for gameplay action
  Future<bool> submitScore(String matchId, {required int scoreDelta, String action = 'action'}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/score/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({'score': scoreDelta, 'action': action}),
      );
      if (kDebugMode) {
        print("[LiveGameService] submitScore [${response.statusCode}]: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] submitScore error: $e");
      return false;
    }
  }

  /// Fan gifting endpoint: verifies coin balance, deducts tokens, awards score
  Future<Map<String, dynamic>?> sendMatchGift(
    String matchId, {
    required String giftType,
    int quantity = 1,
    int? recipientId,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/gift/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'gift_type': giftType,
          'quantity': quantity,
          if (recipientId != null) 'recipient_id': recipientId,
        }),
      );
      if (kDebugMode) {
        print("[LiveGameService] sendMatchGift [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] sendMatchGift error: $e");
    }
    return null;
  }

  /// Surrender / quit match
  Future<bool> quitMatch(String matchId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/quit/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] quitMatch [${response.statusCode}]: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] quitMatch error: $e");
      return false;
    }
  }

  /// Get match result
  Future<Map<String, dynamic>?> getMatchResult(String matchId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/result/');
      final response = await apiClient.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getMatchResult error: $e");
    }
    return null;
  }

  /// Synchronize media state (camera / mic) in match
  Future<bool> updateMediaState(String matchId, {bool? cameraOn, bool? micOn}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.liveGamesMatches}$matchId/media-state/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          if (cameraOn != null) 'camera_on': cameraOn,
          if (micOn != null) 'mic_on': micOn,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] updateMediaState error: $e");
      return false;
    }
  }

  // ==================== LIVE ROOM CO-HOST & GIFTS ====================

  /// Invite user to live room as co-host / 1v1 challenger
  Future<bool> inviteToLiveRoom(String roomId, int userId, {String role = 'co_host'}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/invite/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'user_ids': [userId],
          'role': role,
        }),
      );
      if (kDebugMode) {
        print("[LiveGameService] inviteToLiveRoom [${response.statusCode}]: ${response.body}");
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] inviteToLiveRoom error: $e");
      return false;
    }
  }

  /// Send room gift (rose, galaxy, diamond, crown, heart)
  Future<Map<String, dynamic>?> sendLiveRoomGift(
    String roomId, {
    required String giftType,
    int quantity = 1,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}live/rooms/$roomId/send-gift/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'gift_type': giftType,
          'quantity': quantity,
        }),
      );
      if (kDebugMode) {
        print("[LiveGameService] sendLiveRoomGift [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] sendLiveRoomGift error: $e");
    }
    return null;
  }

  // ==================== USERS & FRIENDS DISCOVERY ====================

  /// Search users to challenge
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authUserList}?search=$encodedQuery');
      final response = await apiClient.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['results'] is List) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] searchUsers error: $e");
    }
    return [];
  }

  /// Get friends to challenge
  Future<List<Map<String, dynamic>>> getFriendsList() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friendsList}');
      final response = await apiClient.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['results'] is List) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getFriendsList error: $e");
    }
    return [];
  }

  // ==================== LIVE QUIZ GAME ====================

  /// 1. List active categories for live room
  Future<List<Map<String, dynamic>>> getQuizCategories(String liveId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}live/$liveId/games/quiz/categories/');
      final response = await apiClient.get(url, headers: _headers);
      if (kDebugMode) {
        print("[LiveGameService] getQuizCategories [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['results'] is List) {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getQuizCategories error: $e");
    }
    return [];
  }

  /// 2. Host creates a new Quiz Game instance for the Live Room
  Future<Map<String, dynamic>?> createQuizGame(String liveId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}live/$liveId/games/quiz/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] createQuizGame [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      try {
        final err = jsonDecode(response.body);
        if (err is Map<String, dynamic> && (err['id'] != null || err['game_id'] != null)) {
          return err;
        }
      } catch (_) {}
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] createQuizGame error: $e");
    }
    return null;
  }

  /// 3. Host selects & locks a category for the game session
  Future<Map<String, dynamic>?> lockQuizCategory(String gameId, String categoryId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/category/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({'category_id': categoryId}),
      );
      if (kDebugMode) {
        print("[LiveGameService] lockQuizCategory [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] lockQuizCategory error: $e");
    }
    return null;
  }

  /// 4. Host starts the next 30-second round
  Future<Map<String, dynamic>?> startQuizRound(String gameId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/start-round/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] startQuizRound [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] startQuizRound error: $e");
    }
    return null;
  }

  /// 5. Participant submits an answer (A–D)
  Future<Map<String, dynamic>?> submitQuizAnswer(
    String gameId,
    String roundId,
    String optionCode, {
    String? idempotencyKey,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/rounds/$roundId/answer/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'option_code': optionCode,
          'idempotency_key': idempotencyKey ?? 'ans_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );
      if (kDebugMode) {
        print("[LiveGameService] submitQuizAnswer [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] submitQuizAnswer error: $e");
    }
    return null;
  }

  /// 6. Server / Host closes the round and computes scores and rewards
  Future<Map<String, dynamic>?> scoreQuizRound(String gameId, String roundId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/rounds/$roundId/score/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] scoreQuizRound [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] scoreQuizRound error: $e");
    }
    return null;
  }

  /// 7. Send fan gifts ($a$) to a quiz guest
  Future<Map<String, dynamic>?> sendQuizGift(
    String gameId, {
    required int recipientUserId,
    required double amount,
    String giftType = 'GALAXY_STAR',
    String? idempotencyKey,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/gift/');
      final response = await apiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'recipient_user_id': recipientUserId,
          'amount': amount.toStringAsFixed(2),
          'gift_type': giftType,
          'idempotency_key': idempotencyKey ?? 'gift_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );
      if (kDebugMode) {
        print("[LiveGameService] sendQuizGift [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] sendQuizGift error: $e");
    }
    return null;
  }

  /// 8. Recover full authoritative state after network disconnect
  Future<Map<String, dynamic>?> getQuizState(String gameId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/state/');
      final response = await apiClient.get(url, headers: _headers);
      if (kDebugMode) {
        print("[LiveGameService] getQuizState [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] getQuizState error: $e");
    }
    return null;
  }

  /// 9. Host or admin ends game; evaluates reward holds & host share
  Future<Map<String, dynamic>?> endQuizGame(String gameId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.quizGames}$gameId/end/');
      final response = await apiClient.post(url, headers: _headers, body: jsonEncode({}));
      if (kDebugMode) {
        print("[LiveGameService] endQuizGame [${response.statusCode}]: ${response.body}");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("[LiveGameService] endQuizGame error: $e");
    }
    return null;
  }
}
