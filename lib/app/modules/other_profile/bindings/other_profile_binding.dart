import 'package:get/get.dart';
import 'package:glotune/app/modules/other_profile/controllers/other_profile_controller.dart';

class OtherProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtherProfileController>(
      () => OtherProfileController(),
    );
  }
}
