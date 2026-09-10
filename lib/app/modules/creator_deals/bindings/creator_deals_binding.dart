import 'package:get/get.dart';
import '../controllers/creator_deals_controller.dart';

class CreatorDealsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatorDealsController>(
      () => CreatorDealsController(),
    );
  }
}
