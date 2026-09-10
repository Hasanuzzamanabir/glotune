import 'package:get/get.dart';
import '../controllers/customize_membership_controller.dart';

class CustomizeMembershipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizeMembershipController>(
      () => CustomizeMembershipController(),
    );
  }
}
