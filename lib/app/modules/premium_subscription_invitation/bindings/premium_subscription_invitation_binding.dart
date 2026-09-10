import 'package:get/get.dart';
import '../controllers/premium_subscription_invitation_controller.dart';

class PremiumSubscriptionInvitationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumSubscriptionInvitationController>(
      () => PremiumSubscriptionInvitationController(),
    );
  }
}
