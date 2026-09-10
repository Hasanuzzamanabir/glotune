import 'package:get/get.dart';
import '../controllers/affiliate_program_controller.dart';

class AffiliateProgramBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AffiliateProgramController>(
      () => AffiliateProgramController(),
    );
  }
}
