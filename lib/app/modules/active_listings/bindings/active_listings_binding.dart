import 'package:get/get.dart';

import '../controllers/active_listings_controller.dart';

class ActiveListingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActiveListingsController>(
      () => ActiveListingsController(),
    );
  }
}
