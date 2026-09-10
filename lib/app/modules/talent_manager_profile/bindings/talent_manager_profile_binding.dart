import 'package:get/get.dart';
import '../controllers/talent_manager_profile_controller.dart';

class TalentManagerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TalentManagerProfileController>(
      () => TalentManagerProfileController(),
    );
  }
}
