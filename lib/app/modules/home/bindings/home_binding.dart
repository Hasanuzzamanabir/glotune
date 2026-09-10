import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'package:glotune/app/modules/community/controllers/community_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<CommunityController>(
      () => CommunityController(),
    );
  }
}
