import 'package:get/get.dart';
import '../controllers/content_creator_profile_controller.dart';

class ContentCreatorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContentCreatorProfileController>(
      () => ContentCreatorProfileController(),
    );
  }
}
