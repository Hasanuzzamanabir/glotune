import 'package:get/get.dart';
import '../controllers/video_statistics_controller.dart';

class VideoStatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoStatisticsController>(
      () => VideoStatisticsController(),
    );
  }
}
