// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:glotune/app/core/network/api_client.dart';
// import 'package:glotune/app/core/values/api_constants.dart';
// import 'package:glotune/app/core/services/auth_service.dart';

// class CommunityController extends GetxController {
//   final selectedTab = "Friends".obs; // Friends, Pending Requests, Inbox
  
//   final friends = <Map<String, dynamic>>[].obs;
//   final isFriendsLoading = false.obs;
  
//   @override
//   void onInit() {
//     super.onInit();
//     fetchFriends();
//     fetchChatList();
//   }

//   Future<void> fetchFriends() async {
//     isFriendsLoading.value = true;
//     try {
//       final authService = Get.find<AuthService>();
//       final token = authService.accessToken.value;
      
//       final headers = <String, String>{};
//       if (token != null) {
//         headers['Authorization'] = 'Bearer $token';
//       }

//       final response = await apiClient.get(
//         Uri.parse('${ApiConstants.baseUrl}friends/list/'),
//         headers: headers,
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final results = data['results'] as List;
//         friends.value = results.cast<Map<String, dynamic>>();
//       } else {
//         print("Failed to fetch friends: ${response.statusCode} ${response.body}");
//       }
//     } catch (e) {
//       print("Error fetching friends: $e");
//     } finally {
//       isFriendsLoading.value = false;
//     }
//   }
  
//   final pendingRequests = [
//     {'name': 'Devon Lane'},
//     {'name': 'Theresa Webb'},
//     {'name': 'Darrell Steward'},
//   ].obs;
  
//   final inbox = <Map<String, dynamic>>[].obs;
//   final isInboxLoading = false.obs;

//   Future<void> fetchChatList() async {
//     isInboxLoading.value = true;
//     try {
//       final authService = Get.find<AuthService>();
//       final token = authService.accessToken.value;
//       if (token == null) return;

//       final response = await apiClient.get(
//         Uri.parse('${ApiConstants.baseUrl}chat/list/'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final results = data['results'] as List;
//         inbox.value = results.cast<Map<String, dynamic>>();
//       } else {
//         print("Failed to fetch chat list: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching chat list: $e");
//     } finally {
//       isInboxLoading.value = false;
//     }
//   }

//   void setTab(String tab) => selectedTab.value = tab;
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class CommunityController extends GetxController {
  final selectedTab = "Friends".obs; // Friends, Pending request, Inbox

  // Friends State
  final friends = <Map<String, dynamic>>[].obs;
  final isFriendsLoading = false.obs;

  // Pending Requests State
  final pendingRequests = <Map<String, dynamic>>[].obs;
  final isRequestsLoading = false.obs;

  // Inbox State
  final inbox = <Map<String, dynamic>>[].obs;
  final isInboxLoading = false.obs;

  // Find Users & Request State
  final allUsers = <Map<String, dynamic>>[].obs;
  final isUsersLoading = false.obs;
  final sentRequestUserIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
    fetchPendingRequests();
    fetchChatList();
  }

  Map<String, String> _getAuthHeaders() {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Fetch Friends List ---
  Future<void> fetchFriends() async {
    isFriendsLoading.value = true;
    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}friends/list/'),
        headers: _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        friends.value = results.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Failed to fetch friends: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching friends: $e");
    } finally {
      isFriendsLoading.value = false;
    }
  }

  // --- Fetch Incoming Friend Requests ---
  Future<void> fetchPendingRequests() async {
    isRequestsLoading.value = true;
    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}friends/requests/list/'),
        headers: _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data is Map && data.containsKey('results'))
            ? data['results'] as List
            : (data as List? ?? []);
        pendingRequests.value = results.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Failed to fetch requests: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    } finally {
      isRequestsLoading.value = false;
    }
  }

  // --- Accept Friend Request ---
  Future<void> acceptFriendRequest(int userId) async {
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}friends/request/accept/'),
        headers: _getAuthHeaders(),
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Friend request accepted",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        fetchPendingRequests();
        fetchFriends();
      } else {
        Get.snackbar(
          "Error",
          "Failed to accept request",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Error accepting request: $e");
    }
  }

  // --- Decline Friend Request ---
  Future<void> declineFriendRequest(int userId) async {
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}friends/request/reject/'),
        headers: _getAuthHeaders(),
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          "Declined",
          "Friend request declined",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        fetchPendingRequests();
      } else {
        pendingRequests.removeWhere((item) => (item['id'] ?? item['user_id']) == userId);
      }
    } catch (e) {
      debugPrint("Error declining request: $e");
    }
  }

  // --- Fetch All Users (Find People) ---
  Future<void> fetchAllUsers({int page = 1}) async {
    isUsersLoading.value = true;
    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}auth/user-list/?page=$page'),
        headers: _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        allUsers.value = results.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isUsersLoading.value = false;
    }
  }

  // --- Send Friend Request ---
Future<void> sendFriendRequest(int userId) async {
  try {
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}friends/request/send/'),
      headers: _getAuthHeaders(),
      body: jsonEncode({"user_id": userId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      sentRequestUserIds.add(userId);
      Get.snackbar(
        "Success",
        data['message'] ?? "Friend request sent successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else if (response.statusCode == 400) {
      final errorMsg = data['error']?.toString().toLowerCase() ?? '';
      
      if (errorMsg.contains('already sent')) {
        sentRequestUserIds.add(userId);
        Get.snackbar(
          "Notice",
          "You have already sent a request to this user",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blueGrey.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Alert",
          data['error'] ?? "Failed to send request",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        "Alert",
        "Could not send friend request (${response.statusCode})",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    debugPrint("Error sending request: $e");
  }
}

  // --- Fetch Inbox / Chat List ---
  Future<void> fetchChatList() async {
    isInboxLoading.value = true;
    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}chat/list/'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        inbox.value = results.cast<Map<String, dynamic>>();
      } else {
        debugPrint("Failed to fetch chat list: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching chat list: $e");
    } finally {
      isInboxLoading.value = false;
    }
  }

  void setTab(String tab) {
    selectedTab.value = tab;
    if (tab == "Friends") fetchFriends();
    if (tab == "Pending request") fetchPendingRequests();
    if (tab == "Inbox") fetchChatList();
  }
}