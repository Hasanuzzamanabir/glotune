import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  final RxBool isPhoneNumber = false.obs;
  final RxString selectedCountryCode = '880'.obs;
  final RxString selectedCountryFlag = '🇧🇩'.obs;
  final RxString selectedCountryCodeAlpha = 'BD'.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_checkInputType);
  }

  void _checkInputType() {
    final text = emailController.text.trim();
    if (text.isEmpty) {
      isPhoneNumber.value = false;
      return;
    }
    final firstChar = text[0];
    if (RegExp(r'[0-9+]').hasMatch(firstChar)) {
      isPhoneNumber.value = true;
    } else {
      isPhoneNumber.value = false;
    }
  }

  void updateCountry(Country country) {
    selectedCountryCode.value = country.phoneCode;
    selectedCountryFlag.value = country.flagEmoji;
    selectedCountryCodeAlpha.value = country.countryCode;
  }

  @override
  void onClose() {
    emailController.removeListener(_checkInputType);
    emailController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final input = emailController.text.trim();
    if (input.isEmpty) {
      Get.snackbar('Error', 'Please enter your email or phone number');
      return;
    }

    isLoading.value = true;
    try {
      if (isPhoneNumber.value) {
        await _registerPhoneNumber(input);
      } else if (GetUtils.isEmail(input)) {
        await _registerEmail(input);
      } else {
        Get.snackbar('Error', 'Please enter a valid email or phone number',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _registerEmail(String email) async {
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}auth/register-email/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Success', data['message'] ?? 'Registration successful',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(Routes.OTP, arguments: {'email': email, 'flow': 'register'});
    } else {
      Get.snackbar('Error', data['message'] ?? 'Registration failed',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _registerPhoneNumber(String phoneNumber) async {
    final countryCode = selectedCountryCodeAlpha.value; 
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}auth/register-phone-number/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'country_code': countryCode,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Success', data['message'] ?? 'Registration successful',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed(Routes.OTP, arguments: {
        'phone_number': phoneNumber,
        'country_code': countryCode,
        'flow': 'register'
      });
    } else {
      Get.snackbar('Error', data['message'] ?? 'Registration failed',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
