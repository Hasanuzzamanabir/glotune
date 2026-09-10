import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateProposalController extends GetxController {
  final agreementType = RxnString();
  
  final agreementTypes = [
    "Creator Media Training",
    "Contracted Collaboration",
    "Creator competition co-host",
    "Merchant Product Interviews",
    "Brand Promo Videos",
  ];

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  
  final uploadedFileName = RxnString();
  final ImagePicker _picker = ImagePicker();

  void setAgreementType(String? value) {
    agreementType.value = value;
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
  }

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
}
