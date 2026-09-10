import 'package:get/get.dart';

import '../controllers/create_new_campaign_controller.dart';

class CreateNewCampaignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewCampaignController>(
      () => CreateNewCampaignController(),
    );
  }
}
