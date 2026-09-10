import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    inputController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final input = inputController.text.trim();
    final password = passwordController.text;

    if (input.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      if (GetUtils.isEmail(input)) {
        await _loginEmail(input, password);
      } else {
        Get.snackbar('Notice', 'Phone login is not implemented yet. Please use email.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loginEmail(String email, String password) async {
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}auth/email-login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token'] ?? data['access'] ?? data['access_token'];
      final refresh = data['refresh'];

      if (token != null) {
        Get.find<AuthService>().saveTokens(access: token, refresh: refresh);
      }
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.snackbar('Error', data['message'] ?? data['detail'] ?? 'Login failed', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
