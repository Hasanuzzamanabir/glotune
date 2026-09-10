import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/notification_settings_controller.dart';

class NotificationSettingsView extends GetView<NotificationSettingsController> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how you want to be notified about activity on Glotune.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            
            _buildSectionTitle('Notification Channels'),
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive notifications on this device',
              value: controller.pushNotifications,
              onChanged: controller.togglePushNotifications,
            ),
            _buildSwitchTile(
              title: 'Email Notifications',
              subtitle: 'Receive daily or weekly summary emails',
              value: controller.emailNotifications,
              onChanged: controller.toggleEmailNotifications,
            ),
            _buildSwitchTile(
              title: 'SMS Notifications',
              subtitle: 'Receive text messages for urgent alerts',
              value: controller.smsNotifications,
              onChanged: controller.toggleSmsNotifications,
            ),
            
            SizedBox(height: 24.h),
            
            _buildSectionTitle('Activity Alerts'),
            _buildSwitchTile(
              title: 'Messages',
              subtitle: 'When someone sends you a direct message',
              value: controller.messageAlerts,
              onChanged: controller.toggleMessageAlerts,
            ),
            _buildSwitchTile(
              title: 'New Followers',
              subtitle: 'When someone follows your channel',
              value: controller.newFollowerAlerts,
              onChanged: controller.toggleNewFollowerAlerts,
            ),
            _buildSwitchTile(
              title: 'Comments & Replies',
              subtitle: 'When someone comments on your content',
              value: controller.commentsAlerts,
              onChanged: controller.toggleCommentsAlerts,
            ),
            _buildSwitchTile(
              title: 'App Updates & Offers',
              subtitle: 'Glotune announcements and promotions',
              value: controller.updatesAlerts,
              onChanged: controller.toggleUpdatesAlerts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(
      () => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
        value: value.value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
