import 'package:get/get.dart';

class BecomePartnerController extends GetxController {
  final institutionName = ''.obs;
  final scopeOfBusiness = ''.obs;
  final countryOfOperations = ''.obs;
  final businessEmail = ''.obs;
  final businessAddress = ''.obs;
  final glotuneAccount = ''.obs;
  
  final selectedLogoPath = ''.obs;

  void updateCountry(String country) {
    countryOfOperations.value = country;
  }
}
