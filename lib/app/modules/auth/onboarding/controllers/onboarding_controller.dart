import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:glotune/app/core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class OnboardingController extends GetxController {
  final currentStep = 1.obs;
  final totalSteps = 8;
  final pageController = PageController();
  final isLoading = false.obs;

  // Data
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final selectedCategory = "".obs;
  final selectedPartnerships = <String>[].obs;
  
  final availableCountries = <String, int>{}.obs;
  final availableCities = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCountries();

    ever(selectedCountry, (String? countryName) {
      selectedCity.value = null;
      availableCities.clear();
      if (countryName != null && availableCountries.containsKey(countryName)) {
        fetchCities(availableCountries[countryName]!);
      }
    });
  }

  Future<void> fetchCountries() async {
    try {
      final response = await apiClient.get(Uri.parse('${ApiConstants.baseUrl}sel/county-list/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        final Map<String, int> countries = {};
        for (var item in results) {
          countries[item['name']] = item['id'];
        }
        availableCountries.value = countries;
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
    }
  }

  Future<void> fetchCities(int countryId) async {
    try {
      final response = await apiClient.get(Uri.parse('${ApiConstants.baseUrl}sel/city-list/?country=$countryId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        final Map<String, int> cities = {};
        for (var item in results) {
          if (item['country'] == countryId) {
            cities[item['name']] = item['id'];
          }
        }
        availableCities.value = cities;
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    }
  }

  final selectedCountry = Rxn<String>();
  final selectedCity = Rxn<String>();
  
  final profileImage = Rxn<File>();
  final isTermsAccepted = false.obs;

  void nextStep() {
    // Step 1: Full Name validation (BR_013)
    if (currentStep.value == 1) {
      final name = fullNameController.text.trim();
      if (name.isEmpty) {
        Get.snackbar('Error', 'Please enter your full name', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        Get.snackbar('Error', 'Full name can only contain alphabetic characters and spaces', snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    // Step 2: Username validation (BR_014)
    if (currentStep.value == 2) {
      final username = usernameController.text.trim();
      if (username.isEmpty) {
        Get.snackbar('Error', 'Please enter a username', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (!RegExp(r'[a-zA-Z]').hasMatch(username)) {
        Get.snackbar('Error', 'Username must contain at least one alphabetical letter', snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    // Step 3: Password validation (BR_015)
    if (currentStep.value == 3) {
      final password = passwordController.text;
      if (password.length < 8) {
        Get.snackbar('Error', 'Password must be at least 8 characters long', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      final hasLower = RegExp(r'[a-z]').hasMatch(password);
      final hasDigit = RegExp(r'[0-9]').hasMatch(password);
      final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
        Get.snackbar(
          'Error',
          'Password must include uppercase, lowercase, numbers, and special symbols',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    if (currentStep.value < totalSteps) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      submitOnboarding();
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  void togglePartnership(String category) {
    if (selectedPartnerships.contains(category)) {
      selectedPartnerships.remove(category);
    } else {
      selectedPartnerships.add(category);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  String _mapEnum(String category) {
    switch (category) {
      case "Content creators":
        return "Creator";
      case "Talent managers":
        return "TalentManager";
      case "Merchants":
        return "Marchant";
      case "Media Network":
        return "Media";
      default:
        return category;
    }
  }

  Future<void> submitOnboarding() async {
    if (!isTermsAccepted.value) {
      Get.snackbar('Error', 'Please accept terms and conditions');
      return;
    }

    final token = Get.find<AuthService>().accessToken.value;
    
    // Convert selected country/city to IDs
    final countryId = selectedCountry.value != null ? availableCountries[selectedCountry.value] : null;
    final cityId = selectedCity.value != null ? availableCities[selectedCity.value] : null;
    
    isLoading.value = true;
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}auth/signup-final/'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['full_name'] = fullNameController.text.trim();
      request.fields['username'] = usernameController.text.trim();
      request.fields['password'] = passwordController.text;
      request.fields['user_type'] = _mapEnum(selectedCategory.value);
      
      if (countryId != null) {
        request.fields['country'] = countryId.toString();
      }
      if (cityId != null) {
        request.fields['city'] = cityId.toString();
      }
      request.fields['i_appreciate'] = isTermsAccepted.value.toString();

      for (final partnership in selectedPartnerships) {
        request.files.add(http.MultipartFile.fromString(
          'partnership',
          _mapEnum(partnership),
        ));
      }

      if (profileImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profileImage.value!.path,
        ));
      }

      final streamedResponse = await apiClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAllNamed(Routes.SUCCESS); // Navigate to success or main
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
