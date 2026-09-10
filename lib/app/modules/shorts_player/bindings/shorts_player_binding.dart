import 'package:get/get.dart';
import '../controllers/shorts_player_controller.dart';

class ShortsPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShortsPlayerController>(
      () => ShortsPlayerController(),
    );
  }
}
