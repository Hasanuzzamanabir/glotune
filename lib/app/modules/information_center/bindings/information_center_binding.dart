import 'package:get/get.dart';
import '../controllers/information_center_controller.dart';

class InformationCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformationCenterController>(
      () => InformationCenterController(),
    );
  }
}
