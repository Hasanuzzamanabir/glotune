import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class NotificationsController extends GetxController {
  final selectedIndex = 0.obs;
  final notifications = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}notifications/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        notifications.value = results.cast<Map<String, dynamic>>();
      } else {
        print("Failed to fetch notifications: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.delete(
        Uri.parse('${ApiConstants.baseUrl}notifications/delete-all/'),
        headers: headers,
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        notifications.clear();
        Get.snackbar("Success", "All notifications deleted", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to delete notifications", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.put(
        Uri.parse('${ApiConstants.baseUrl}notifications/mark-all-read/'),
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local state
        final updatedNotifications = notifications.map((n) {
          final newNotification = Map<String, dynamic>.from(n);
          newNotification['is_read'] = true;
          return newNotification;
        }).toList();
        notifications.value = updatedNotifications;
        
        Get.snackbar("Success", "All notifications marked as read", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to mark notifications as read", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.patch(
        Uri.parse('${ApiConstants.baseUrl}notifications/$id/mark-read/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        final index = notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          final updated = Map<String, dynamic>.from(notifications[index]);
          updated['is_read'] = true;
          notifications[index] = updated;
        }
      }
    } catch (e) {
      print("Error marking notification $id as read: $e");
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.delete(
        Uri.parse('${ApiConstants.baseUrl}notifications/$id/delete/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 204 || response.statusCode == 200) {
        notifications.removeWhere((n) => n['id'] == id);
        Get.snackbar("Success", "Notification deleted", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not delete notification: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> showNotificationDetails(int id) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      Get.dialog(const Center(child: CircularProgressIndicator()));

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}notifications/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      Get.back(); // close loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['title'] ?? 'Details';
        final message = data['message'] ?? '';
        
        Get.defaultDialog(
          title: title,
          middleText: message,
          textConfirm: "Close",
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
        
        // Also mark as read locally if not already
        if (data['is_read'] != true) {
          markNotificationAsRead(id);
        }
      } else {
        Get.snackbar("Error", "Could not load details", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back(); // close loading if error
      Get.snackbar("Error", "Something went wrong: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
