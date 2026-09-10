import 'package:get/get.dart';
import '../controllers/studio_controller.dart';

class StudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudioController>(() => StudioController());
  }
}
