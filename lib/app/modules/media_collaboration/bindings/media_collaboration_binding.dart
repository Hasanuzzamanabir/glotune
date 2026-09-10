import 'package:get/get.dart';
import '../controllers/media_collaboration_controller.dart';

class MediaCollaborationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaCollaborationController>(
      () => MediaCollaborationController(),
    );
  }
}
