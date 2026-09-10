import 'package:get/get.dart';
import '../controllers/viewer_profile_controller.dart';

class ViewerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewerProfileController>(() => ViewerProfileController());
  }
}
