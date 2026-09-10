import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchingSystemController extends GetxController {
  final pageController = PageController();
  final currentStep = 0.obs; // This will map to Step 2, 3, 4 (0, 1, 2 index)
  
  // Step 2: Self ID
  final selectedCategory = "".obs;
  final categories = [
    "Content creator",
    "Talent manager",
    "Merchant",
    "Media Network",
  ];

  // Step 3: Partner Preference
  final selectedPartner = "".obs;
  final partners = [
    "Content creator",
    "Talent manager",
    "Merchant",
    "Media Network",
    "None",
  ];

  // Step 4: Geographic Targeting
  final selectedCountries = <String>[].obs;
  final availableCountries = [
    "United States",
    "United Kingdom",
    "Canada",
    "Australia",
    "Germany",
    "France",
    "Brazil",
    "India",
    "China",
    "Japan",
  ];

  bool get canProceed {
    if (currentStep.value == 0) return selectedCategory.isNotEmpty;
    if (currentStep.value == 1) return selectedPartner.isNotEmpty;
    if (currentStep.value == 2) return selectedCountries.isNotEmpty;
    return false;
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Submit the questionnaire
      Get.back();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.back();
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void selectPartner(String partner) {
    selectedPartner.value = partner;
  }

  void toggleCountry(String country) {
    if (selectedCountries.contains(country)) {
      selectedCountries.remove(country);
    } else {
      selectedCountries.add(country);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
