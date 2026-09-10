import 'package:get/get.dart';
import '../controllers/login_options_controller.dart';

class LoginOptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginOptionsController>(
      () => LoginOptionsController(),
    );
  }
}
