import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class GroupDetailsController extends GetxController {
  final Map<String, dynamic> groupInfo = Get.arguments ?? {};
  final groupId = 0.obs;
  
  final groupDetails = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    groupId.value = groupInfo['id'] ?? 0;
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    if (groupId.value == 0) return;
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        groupDetails.value = jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching group details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMember(int userId, String role) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final body = {"user": userId, "role": role};

      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/add-member/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Member added", snackPosition: SnackPosition.BOTTOM);
        fetchGroupDetails();
      } else {
        Get.snackbar("Error", "Failed to add member", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> promoteMember(int memberId, int userId) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final body = {"user": userId, "role": "admin"};

      final response = await apiClient.put(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/promote-member/$memberId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Member promoted", snackPosition: SnackPosition.BOTTOM);
        fetchGroupDetails();
      } else {
        Get.snackbar("Error", "Failed to promote", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> demoteMember(int memberId, int userId) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final body = {"user": userId, "role": "member"};

      final response = await apiClient.put(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/demote-member/$memberId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Member demoted", snackPosition: SnackPosition.BOTTOM);
        fetchGroupDetails();
      } else {
        Get.snackbar("Error", "Failed to demote", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> leaveGroup(int userId, String role) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final body = {"user": userId, "role": role};

      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/leave/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        Get.back(result: true); // go back to group list
        Get.snackbar("Success", "Left group successfully", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to leave group", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removeMember(int memberId) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.delete(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/remove-member/$memberId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Member removed", snackPosition: SnackPosition.BOTTOM);
        fetchGroupDetails();
      } else {
        Get.snackbar("Error", "Failed to remove member", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteGroup() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.delete(
        Uri.parse('${ApiConstants.baseUrl}group-chat/${groupId.value}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back(result: true);
        Get.snackbar("Success", "Group deleted", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to delete group", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
