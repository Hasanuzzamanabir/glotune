import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/subscriber_item.dart';

class SubscribersController extends GetxController {
  final subscribers = <SubscriberItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchSubscribers();
  }

  Future<void> fetchSubscribers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}user/subscriber/list/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        subscribers.value = results.map((e) => SubscriberItem.fromJson(e)).toList();
      } else {
        errorMessage.value = 'Failed to load subscribers: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching subscribers: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void removeSubscriber(int index) {
    subscribers.removeAt(index);
    Get.snackbar(
      'Removed',
      'Subscriber has been removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
