import 'package:get/get.dart';
import '../controllers/engagement_history_controller.dart';

class EngagementHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EngagementHistoryController>(() => EngagementHistoryController());
  }
}
