import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:intl/intl.dart';

class AddCreatorController extends GetxController {
  final _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final commentsController = TextEditingController();
  
  final talentType = 'influencer'.obs;
  final companyType = 'individual'.obs;
  final managementType = 'affiliate'.obs;
  final managementStartDate = Rxn<DateTime>();

  final isLoading = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    commentsController.dispose();
    super.onClose();
  }

  void pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      managementStartDate.value = picked;
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    if (managementStartDate.value == null) {
      Get.snackbar('Error', 'Please select a management start date.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final token = _authService.accessToken.value;
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.contentCreatorsList);
      
      final payload = {
        'creator_username': usernameController.text.trim(),
        'creator_email': emailController.text.trim(),
        'talent_type': talentType.value,
        'company_type': companyType.value,
        'management_start_date': DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(managementStartDate.value!),
        'management_type': managementType.value,
        'add_comments': commentsController.text.trim(),
      };

      final response = await apiClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar('Success', 'Creator added successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Failed to add creator: ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
