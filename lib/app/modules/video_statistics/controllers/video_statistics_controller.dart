import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/video_statistics.dart';

class VideoStatisticsController extends GetxController {
  final isLoading = false.obs;
  final statistics = Rx<VideoStatistics?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchVideoStatistics();
  }

  Future<void> fetchVideoStatistics() async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}profile/video-stats/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        statistics.value = VideoStatistics.fromJson(data);
      } else {
        print("Failed to load video statistics: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching video statistics: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
