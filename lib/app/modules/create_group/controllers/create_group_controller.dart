import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class CreateGroupController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final friends = <Map<String, dynamic>>[].obs;
  final selectedFriends = <int>[].obs;
  final isFriendsLoading = false.obs;
  final isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchFriends() async {
    isFriendsLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}friends/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        friends.value = results.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      isFriendsLoading.value = false;
    }
  }

  void toggleFriendSelection(int id) {
    if (selectedFriends.contains(id)) {
      selectedFriends.remove(id);
    } else {
      selectedFriends.add(id);
    }
  }

  Future<void> createGroup() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Group name is required", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isCreating.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final body = {
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
        "members": selectedFriends.toList(),
      };

      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}group-chat/create/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Get.back(result: true); // Return true to indicate success
        Get.snackbar("Success", "Group created successfully", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to create group", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCreating.value = false;
    }
  }
}
