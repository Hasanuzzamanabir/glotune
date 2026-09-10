import 'package:get/get.dart';

import '../controllers/campaign_management_controller.dart';

class CampaignManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CampaignManagementController>(
      () => CampaignManagementController(),
    );
  }
}
