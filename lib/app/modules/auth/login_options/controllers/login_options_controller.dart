import 'package:get/get.dart';

class LoginOptionsController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      // Initiate Google Sign-In flow
      Get.snackbar('Google Sign-In', 'Google Sign-In initiated...',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Google Sign-In failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

