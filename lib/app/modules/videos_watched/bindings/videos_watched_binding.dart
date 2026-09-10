import 'package:get/get.dart';
import '../controllers/videos_watched_controller.dart';

class VideosWatchedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideosWatchedController>(() => VideosWatchedController());
  }
}
