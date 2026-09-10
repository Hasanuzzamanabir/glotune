import 'package:get/get.dart';
import '../controllers/affiliate_tools_controller.dart';

class AffiliateToolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AffiliateToolsController>(
      () => AffiliateToolsController(),
    );
  }
}
