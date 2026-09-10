import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/information_center_model.dart';

class InformationCenterController extends GetxController {
  final isLoading = false.obs;
  final infoData = Rxn<InformationCenterModel>();

  @override
  void onInit() {
    super.onInit();
    fetchInfoCenterData();
  }

  Future<void> fetchInfoCenterData() async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}profile/information-center/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        infoData.value = InformationCenterModel.fromJson(data);
      } else {
        print("Failed to load information center data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching information center data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
