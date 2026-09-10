import 'package:get/get.dart';
import '../controllers/location_settings_controller.dart';

class LocationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationSettingsController>(
      () => LocationSettingsController(),
    );
  }
}
