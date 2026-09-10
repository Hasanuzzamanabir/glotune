import 'package:get/get.dart';
import '../controllers/deals_management_controller.dart';

class DealsManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DealsManagementController>(
      () => DealsManagementController(),
    );
  }
}
