import 'package:get/get.dart';

import '../controllers/total_products_controller.dart';

class TotalProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TotalProductsController>(
      () => TotalProductsController(),
    );
  }
}
