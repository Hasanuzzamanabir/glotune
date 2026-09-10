import 'package:get/get.dart';

class TalentManagerProfileController extends GetxController {
  final openInviteForCreators = true.obs;

  void toggleOpenInvite(bool value) {
    openInviteForCreators.value = value;
  }
}
