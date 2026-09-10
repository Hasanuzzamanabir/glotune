import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ManagerVerificationController extends GetxController {
  final uploadedFileName = RxnString();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickFile() async {
    try {
      final XFile? file = await _picker.pickMedia();
      if (file != null) {
        uploadedFileName.value = file.name;
      }
    } catch (e) {
      Get.snackbar("Error", "Could not pick file");
    }
  }

  void submitVerification() {
    // Implement submission logic
    Get.snackbar("Success", "Verification submitted successfully");
  }
}
