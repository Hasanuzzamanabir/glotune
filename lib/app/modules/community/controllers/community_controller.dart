import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class CommunityController extends GetxController {
  final selectedTab = "Friends".obs; // Friends, Pending Requests, Inbox
  
  final friends = <Map<String, dynamic>>[].obs;
  final isFriendsLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchFriends();
    fetchChatList();
  }

  Future<void> fetchFriends() async {
    isFriendsLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}friends/list/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        friends.value = results.cast<Map<String, dynamic>>();
      } else {
        print("Failed to fetch friends: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      isFriendsLoading.value = false;
    }
  }
  
  final pendingRequests = [
    {'name': 'Devon Lane'},
    {'name': 'Theresa Webb'},
    {'name': 'Darrell Steward'},
  ].obs;
  
  final inbox = <Map<String, dynamic>>[].obs;
  final isInboxLoading = false.obs;

  Future<void> fetchChatList() async {
    isInboxLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}chat/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        inbox.value = results.cast<Map<String, dynamic>>();
      } else {
        print("Failed to fetch chat list: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chat list: $e");
    } finally {
      isInboxLoading.value = false;
    }
  }

  void setTab(String tab) => selectedTab.value = tab;
}
