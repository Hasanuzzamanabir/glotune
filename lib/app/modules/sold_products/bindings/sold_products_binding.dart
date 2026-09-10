import 'package:get/get.dart';

import '../controllers/sold_products_controller.dart';

class SoldProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SoldProductsController>(
      () => SoldProductsController(),
    );
  }
}
