import 'package:get/get.dart';

class ContentCreatorProfileController extends GetxController {
  final isManagedByTalentManager = false.obs;

  void toggleTalentManager(bool value) {
    isManagedByTalentManager.value = value;
  }
}
