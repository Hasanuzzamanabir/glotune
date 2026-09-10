import 'package:get/get.dart';
import '../controllers/make_donation_controller.dart';

class MakeDonationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MakeDonationController>(
      () => MakeDonationController(),
    );
  }
}
