import 'package:get/get.dart';
import '../controllers/video_shared_controller.dart';

class VideoSharedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoSharedController>(() => VideoSharedController());
  }
}
