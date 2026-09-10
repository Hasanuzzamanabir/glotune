import 'package:get/get.dart';
import '../controllers/become_partner_controller.dart';

class BecomePartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BecomePartnerController>(
      () => BecomePartnerController(),
    );
  }
}
