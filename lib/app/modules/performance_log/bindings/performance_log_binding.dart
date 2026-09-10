import 'package:get/get.dart';
import '../controllers/performance_log_controller.dart';

class PerformanceLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerformanceLogController>(
      () => PerformanceLogController(),
    );
  }
}
