import 'package:get/get.dart';
import '../controllers/premium_subscription_controller.dart';

class PremiumSubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumSubscriptionController>(
      () => PremiumSubscriptionController(),
    );
  }
}
