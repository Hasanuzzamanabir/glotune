import 'package:get/get.dart';
import 'package:glotune/app/modules/live_player/controllers/live_player_controller.dart';

class LivePlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LivePlayerController>(
      () => LivePlayerController(),
    );
  }
}
