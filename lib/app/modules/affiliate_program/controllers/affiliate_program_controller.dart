import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/affiliate_stats.dart';

class AffiliateProgramController extends GetxController {
  final isLoading = false.obs;
  final stats = Rx<AffiliateStats?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAffiliateStats();
  }

  Future<void> fetchAffiliateStats() async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}profile/affiliate-stats/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        stats.value = AffiliateStats.fromJson(data);
      } else {
        print("Failed to load affiliate stats: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching affiliate stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Placeholder for RevenueCat implementation
  Future<void> upgradeToTier(String tier) async {
    try {
      // TODO: Implement RevenueCat purchase logic here
      // final customerInfo = await Purchases.purchasePackage(package);
      print("Initiating upgrade to $tier via RevenueCat (Placeholder)");
      Get.snackbar(
        "Upgrade Initiated",
        "Purchasing $tier tier...",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("Upgrade error: $e");
      Get.snackbar(
        "Upgrade Failed",
        "Could not process upgrade: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
