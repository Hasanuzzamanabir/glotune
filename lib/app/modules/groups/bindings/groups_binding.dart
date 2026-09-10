import 'package:get/get.dart';
import 'package:glotune/app/modules/groups/controllers/groups_controller.dart';

class GroupsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupsController>(
      () => GroupsController(),
    );
  }
}
