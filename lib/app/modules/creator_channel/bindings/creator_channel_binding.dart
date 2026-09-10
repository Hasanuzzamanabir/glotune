import 'package:get/get.dart';
import '../controllers/creator_channel_controller.dart';

class CreatorChannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatorChannelController>(() => CreatorChannelController());
  }
}
