import 'package:get/get.dart';

import '../controllers/manage_creators_controller.dart';

class ManageCreatorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageCreatorsController>(
      () => ManageCreatorsController(),
    );
  }
}
