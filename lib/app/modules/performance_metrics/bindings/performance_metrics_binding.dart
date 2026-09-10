import 'package:get/get.dart';
import '../controllers/performance_metrics_controller.dart';

class PerformanceMetricsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerformanceMetricsController>(
      () => PerformanceMetricsController(),
    );
  }
}
