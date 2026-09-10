import 'package:get/get.dart';

import '../controllers/add_new_product_controller.dart';

class AddNewProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddNewProductController>(
      () => AddNewProductController(),
    );
  }
}
