import 'package:get/get.dart';
import '../controllers/reselling_analytics_controller.dart';

class ResellingAnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResellingAnalyticsController>(
      () => ResellingAnalyticsController(),
    );
  }
}
