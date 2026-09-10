import 'package:get/get.dart';
import '../controllers/proposal_details_controller.dart';

class ProposalDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProposalDetailsController>(
      () => ProposalDetailsController(),
    );
  }
}
