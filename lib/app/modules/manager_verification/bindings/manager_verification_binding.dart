import 'package:get/get.dart';
import '../controllers/manager_verification_controller.dart';

class ManagerVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerVerificationController>(
      () => ManagerVerificationController(),
    );
  }
}
