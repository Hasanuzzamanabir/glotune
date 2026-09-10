import 'package:get/get.dart';
import '../controllers/premium_sub_reselling_controller.dart';

class PremiumSubResellingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumSubResellingController>(
      () => PremiumSubResellingController(),
    );
  }
}
