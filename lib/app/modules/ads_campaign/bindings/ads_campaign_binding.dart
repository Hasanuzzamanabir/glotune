import 'package:get/get.dart';

import '../controllers/ads_campaign_controller.dart';

class AdsCampaignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdsCampaignController>(
      () => AdsCampaignController(),
    );
  }
}
