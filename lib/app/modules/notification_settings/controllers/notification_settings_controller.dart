import 'package:get/get.dart';

class NotificationSettingsController extends GetxController {
  final pushNotifications = true.obs;
  final emailNotifications = false.obs;
  final smsNotifications = false.obs;
  
  final messageAlerts = true.obs;
  final newFollowerAlerts = true.obs;
  final commentsAlerts = true.obs;
  final updatesAlerts = false.obs;

  void togglePushNotifications(bool value) => pushNotifications.value = value;
  void toggleEmailNotifications(bool value) => emailNotifications.value = value;
  void toggleSmsNotifications(bool value) => smsNotifications.value = value;
  
  void toggleMessageAlerts(bool value) => messageAlerts.value = value;
  void toggleNewFollowerAlerts(bool value) => newFollowerAlerts.value = value;
  void toggleCommentsAlerts(bool value) => commentsAlerts.value = value;
  void toggleUpdatesAlerts(bool value) => updatesAlerts.value = value;
}
