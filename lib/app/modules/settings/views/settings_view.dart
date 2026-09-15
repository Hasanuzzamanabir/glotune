import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:share_plus/share_plus.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsCard(
                title: 'General settings',
                items: [
                  _buildSettingsItem(
                    icon: Icons.g_translate_rounded,
                    title: 'Language selection',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.campaign_rounded,
                    title: 'Ads Campaign',
                    onTap: () => Get.toNamed(Routes.ADS_CAMPAIGN),
                  ),
                  _buildSettingsItem(
                    icon: Icons.keyboard_double_arrow_down_rounded,
                    title: 'Earn badges',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.location_on_rounded,
                    title: 'Location settings',
                    onTap: () => Get.toNamed(Routes.LOCATION_SETTINGS),
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications_rounded,
                    title: 'Notification settings',
                    onTap: () => Get.toNamed(Routes.NOTIFICATION_SETTINGS),
                  ),
                  _buildSettingsItem(
                    icon: Icons.handshake_outlined,
                    title: 'Become a partner organization',
                    onTap: () => Get.toNamed(Routes.BECOME_PARTNER),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildSettingsCard(
                title: 'Account',
                items: [
                  _buildSettingsItem(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Get GloTune premium',
                    onTap: () => Get.toNamed(Routes.PREMIUM_SUBSCRIPTION),
                  ),
                  _buildSettingsItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Partnership Analytics',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Donations',
                    onTap: () => Get.toNamed(Routes.DONATIONS),
                  ),
                  _buildSettingsItem(
                    icon: Icons.monetization_on_rounded,
                    title: 'Earnings',
                    onTap: () => Get.toNamed(Routes.EARNINGS),
                  ),
                  _buildSettingsItem(
                    icon: Icons.edit_note_rounded,
                    title: 'Customize membership subscription',
                    onTap: () => Get.toNamed(Routes.CUSTOMIZE_MEMBERSHIP),
                  ),
                  _buildSettingsItem(
                    icon: Icons.how_to_reg_rounded,
                    title: 'Matching system',
                    onTap: () => Get.toNamed(Routes.MATCHING_SYSTEM),
                  ),
                  _buildSettingsItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Purchases',
                    onTap: () => Get.toNamed(Routes.PURCHASES),
                  ),
                  _buildSettingsItem(
                    icon: Icons.support_rounded,
                    title: 'Subscribers',
                    onTap: () => Get.toNamed(Routes.SUBSCRIBERS),
                  ),
                  _buildSettingsItem(
                    icon: Icons.support_rounded,
                    title: 'Support',
                    onTap: () => Get.toNamed(Routes.SUPPORT),
                  ),
                  _buildSettingsItem(
                    icon: Icons.ios_share_rounded,
                    title: 'Invite a friend',
                    onTap: () {
                      Share.share(
                        'Check out GloTune! The best app for creators and merchants. Download it now at: https://glotune.com',
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Register for season competition',
                    onTap: () => Get.toNamed(Routes.COMPETITION_FORM),
                  ),
                  _buildSettingsItem(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Terms of service',
                    onTap: () => Get.toNamed(Routes.TERMS_OF_SERVICE),
                  ),
                  _buildSettingsItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    onTap: controller.logout,
                  ),
                  _buildSettingsItem(
                    icon: Icons.delete_rounded,
                    title: 'Delete Account',
                    onTap: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items,
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    IconData? icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: AppColors.primary, size: 22.sp)
            else
              SizedBox(width: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteAccount();
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
