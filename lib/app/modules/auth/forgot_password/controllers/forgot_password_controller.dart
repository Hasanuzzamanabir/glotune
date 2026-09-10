import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController inputController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  Future<void> requestOtp() async {
    final input = inputController.text.trim();

    if (input.isEmpty) {
      Get.snackbar('Error', 'Please enter your email or phone number', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      if (GetUtils.isEmail(input)) {
        await _requestEmailOtp(input);
      } else {
        Get.snackbar('Notice', 'Phone number reset not fully implemented yet.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _requestEmailOtp(String email) async {
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}auth/request-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_reason': 'SetPassword',
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Success', data['message'] ?? 'OTP sent successfully', snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(Routes.OTP, arguments: {'email': email, 'flow': 'forgot'});
    } else {
      Get.snackbar('Error', data['message'] ?? 'Failed to send OTP', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
