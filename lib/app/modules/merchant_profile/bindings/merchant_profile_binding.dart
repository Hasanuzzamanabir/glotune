import 'package:get/get.dart';
import '../controllers/merchant_profile_controller.dart';

class MerchantProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantProfileController>(
      () => MerchantProfileController(),
    );
  }
}
