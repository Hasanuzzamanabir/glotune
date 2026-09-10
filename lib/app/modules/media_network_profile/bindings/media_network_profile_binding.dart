import 'package:get/get.dart';

import '../controllers/media_network_profile_controller.dart';

class MediaNetworkProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaNetworkProfileController>(
      () => MediaNetworkProfileController(),
    );
  }
}
