import 'package:get/get.dart';

import '../controllers/inventory_management_controller.dart';

class InventoryManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryManagementController>(
      () => InventoryManagementController(),
    );
  }
}
