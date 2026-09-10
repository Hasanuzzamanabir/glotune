import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/campaign.dart';

class AdsCampaignController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }
  final campaignTypes = [
    '1. Splash (while app is loading) = \$5 CPM\n    max time: 5 seconds',
    '2. Masthead (at top of homescreen)\n    max time: 3 minutes = \$100/day',
    '3. Overlay for shorts (at top of short video)\n    max time: 2 minutes = \$8 CPM',
    '4. Overlay for shorts (at bottom of short video)\n    max time: 2 minutes = \$8 CPM',
    '5. Overlay for landscape (bottom of landscape video)\n    max time: 2 minutes = \$8 CPM',
    '6. Display for landscape (leftside of landscape video)\n    max time: 2 minutes = \$8 CPM',
    '7. Pre-roll for landscape video (before video starts)\n    max time: 20 seconds = \$10 CPM',
    '8. Mid-roll for landscape video (middle of the video)\n    max time: 20 seconds = \$10 CPM',
    '9. Post-roll for landscape (at the end of the video)\n    max time: 20 minutes = \$6 CPM',
  ];

  final selectedCampaignType = Rx<String?>(null);
  final selectedFileName = Rx<String?>(null);

  // Step 2 Observables
  final targetAudience = 'Male'.obs;
  final country = Rx<String?>(null);
  final city = Rx<String?>(null);
  final language = Rx<String?>(null);
  
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  
  final frequency = Rx<String?>('Daily');
  final paymentOption = Rx<String?>('Stripe');
  final budgetSetting = Rx<String?>('Daily Spend Cap');

  // New form fields for API
  final titleController = TextEditingController();
  final costController = TextEditingController();
  
  final campaignTypesEnum = ['awareness', 'engagement', 'conversion'];
  final selectedCampaignTypeEnum = Rx<String?>(null);
  
  final paymentMethods = ['credit_card', 'debit_card'];
  final selectedPaymentMethod = Rx<String?>('credit_card');
  
  final isSubmitting = false.obs;

  Future<void> submitCampaign() async {
    final title = titleController.text.trim();
    final cost = costController.text.trim();
    
    if (title.isEmpty || cost.isEmpty || startDate.value == null || endDate.value == null || selectedCampaignTypeEnum.value == null) {
      Get.snackbar("Error", "Please fill all required fields", backgroundColor: Colors.white, colorText: Colors.black);
      return;
    }

    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return;

    isSubmitting.value = true;
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}campaign/create/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "start_time": startDate.value!.toIso8601String(),
          "end_time": endDate.value!.toIso8601String(),
          "campain_cost": cost, // Note the spelling in API
          "paytment_method": selectedPaymentMethod.value, // Note the spelling in API
          "frequency": frequency.value ?? "daily",
          "campaign_type": selectedCampaignTypeEnum.value,
          "country": 1, // Mock ID
          "city": 1, // Mock ID
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar("Success", "Campaign created successfully!", backgroundColor: Colors.white, colorText: Colors.black);
        Get.back();
        Get.back();
      } else {
        Get.snackbar("Error", "Failed to create campaign: ${response.statusCode}", backgroundColor: Colors.white, colorText: Colors.black);
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred", backgroundColor: Colors.white, colorText: Colors.black);
    } finally {
      isSubmitting.value = false;
    }
  }

  final isCampaignsLoading = false.obs;
  final RxList<Campaign> campaignList = <Campaign>[].obs;

  Future<void> fetchCampaigns() async {
    isCampaignsLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}campaign/list/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        campaignList.value = data.map((json) => Campaign.fromJson(json)).toList();
      } else {
        print("Failed to load campaigns: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching campaigns: $e");
    } finally {
      isCampaignsLoading.value = false;
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickFile() async {
    final XFile? file = await _picker.pickMedia();
    if (file != null) {
      selectedFileName.value = file.name;
    }
  }
}
