import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/services/auth_service.dart';

class SettingsController extends GetxController {
  // Add any logic for settings here
  
  void deleteAccount() {
    // Logic for deleting account
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthService>().clearTokens();
              Get.offAllNamed(Routes.LOGIN_OPTIONS);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
