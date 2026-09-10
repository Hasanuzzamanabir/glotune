import 'package:get/get.dart';
import '../controllers/scouting_tools_controller.dart';

class ScoutingToolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScoutingToolsController>(
      () => ScoutingToolsController(),
    );
  }
}
