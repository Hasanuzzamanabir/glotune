import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/campaign.dart';

class CampaignManagementController extends GetxController {
  final isCampaignsLoading = false.obs;
  final RxList<Campaign> campaignList = <Campaign>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

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
}
