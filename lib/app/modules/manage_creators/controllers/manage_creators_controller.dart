import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/data/models/content_creator.dart';

class ManageCreatorsController extends GetxController {
  final _authService = Get.find<AuthService>();
  final RxList<ContentCreator> creators = <ContentCreator>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCreators();
  }

  Future<void> fetchCreators() async {
    isLoading.value = true;
    error.value = '';
    try {
      final token = _authService.accessToken.value;
      if (token == null) {
        error.value = 'User not authenticated';
        return;
      }

      final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.contentCreatorsList);
      final response = await apiClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        creators.value = data.map((json) => ContentCreator.fromJson(json)).toList();
      } else {
        error.value = 'Failed to load creators (Status: ${response.statusCode})';
      }
    } catch (e) {
      error.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void removeCreator(int index) {
    // TODO: Implement backend removal if necessary
    creators.removeAt(index);
    Get.snackbar('Success', 'Creator removed');
  }

  void editCreator(int index) {
    // Navigate to edit creator screen
    // Get.toNamed(Routes.EDIT_CREATOR, arguments: creators[index]);
  }
}
