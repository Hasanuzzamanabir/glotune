import 'package:get/get.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN_OPTIONS);
    }
  }
}
