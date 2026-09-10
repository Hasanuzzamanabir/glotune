import 'package:get/get.dart';
import '../controllers/create_proposal_controller.dart';

class CreateProposalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateProposalController>(
      () => CreateProposalController(),
    );
  }
}
