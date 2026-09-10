import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/routes/app_pages.dart';

class CreatePasswordController extends GetxController {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> setPassword() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Please fill in both fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final args = Get.arguments ?? {};
    final email = args['email'];
    final otp = args['otp'];

    if (email == null || otp == null) {
      Get.snackbar('Error', 'Missing required information (email or otp). Please start over.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}auth/set-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', data['message'] ?? 'Password reset successfully', snackPosition: SnackPosition.BOTTOM);
        // After successful reset, pop back to the existing login screen
        Get.until((route) => route.settings.name == Routes.LOGIN);
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to reset password', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
