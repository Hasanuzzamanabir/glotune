import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/performance_metrics.dart';

class PerformanceMetricsController extends GetxController {
  final isLoading = false.obs;
  final metrics = Rx<PerformanceMetrics?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchPerformanceMetrics();
  }

  Future<void> fetchPerformanceMetrics() async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}profile/performance-matrix/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        metrics.value = PerformanceMetrics.fromJson(data);
      } else {
        print("Failed to load performance metrics: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching performance metrics: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
