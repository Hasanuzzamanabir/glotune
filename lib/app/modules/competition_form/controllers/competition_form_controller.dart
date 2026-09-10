import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CompetitionFormController extends GetxController {
  final currentStep = 1.obs;
  
  void nextStep() {
    if (currentStep.value < 4) {
      currentStep.value++;
    }
  }
  
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  void submitForm() async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    Get.back(); // Close loading dialog

    Get.defaultDialog(
      title: 'Success',
      middleText: 'Your registration has been submitted successfully.',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF8B1D1D), // AppColors.primary
      onConfirm: () {
        Get.back(); // Close dialog
        Get.back(); // Go back to previous screen (Settings)
      },
    );
  }
}
