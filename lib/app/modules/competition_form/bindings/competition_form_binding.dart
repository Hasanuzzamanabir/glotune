import 'package:get/get.dart';
import '../controllers/competition_form_controller.dart';

class CompetitionFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompetitionFormController>(
      () => CompetitionFormController(),
    );
  }
}
