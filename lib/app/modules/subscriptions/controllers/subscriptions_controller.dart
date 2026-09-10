import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class SubscriptionsController extends GetxController {
  final subscriptions = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}user/subscriber/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        subscriptions.value = results.cast<Map<String, dynamic>>();
      } else {
        print("Failed to fetch subscriptions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching subscriptions: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
