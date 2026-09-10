import 'package:get/get.dart';

import '../controllers/add_creator_controller.dart';

class AddCreatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddCreatorController>(
      () => AddCreatorController(),
    );
  }
}
