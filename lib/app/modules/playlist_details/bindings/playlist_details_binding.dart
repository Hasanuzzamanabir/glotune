import 'package:get/get.dart';

import '../controllers/playlist_details_controller.dart';

class PlaylistDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaylistDetailsController>(
      () => PlaylistDetailsController(),
    );
  }
}
