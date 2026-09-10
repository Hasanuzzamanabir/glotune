import 'package:get/get.dart';
import '../controllers/create_deal_controller.dart';

class CreateDealBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateDealController>(
      () => CreateDealController(),
    );
  }
}
