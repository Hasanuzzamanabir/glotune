import 'package:get/get.dart';

class LocationSettingsController extends GetxController {
  final enableLocationServices = true.obs;
  final shareLocationWithMerchants = false.obs;
  final usePreciseLocation = true.obs;
  
  final selectedRegion = 'United States'.obs;
  
  final regions = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'India',
    'Germany',
    'France',
  ];

  void toggleLocationServices(bool value) => enableLocationServices.value = value;
  void toggleShareLocation(bool value) => shareLocationWithMerchants.value = value;
  void togglePreciseLocation(bool value) => usePreciseLocation.value = value;
}
