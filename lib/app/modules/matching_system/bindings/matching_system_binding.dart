import 'package:get/get.dart';
import '../controllers/matching_system_controller.dart';

class MatchingSystemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchingSystemController>(
      () => MatchingSystemController(),
    );
  }
}
