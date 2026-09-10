import 'package:get/get.dart';
import '../controllers/sponsorship_center_controller.dart';

class SponsorshipCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SponsorshipCenterController>(
      () => SponsorshipCenterController(),
    );
  }
}
