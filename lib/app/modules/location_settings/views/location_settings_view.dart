import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/location_settings_controller.dart';

class LocationSettingsView extends GetView<LocationSettingsController> {
  const LocationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Settings',
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
              'Manage your location preferences and privacy settings below.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),

            _buildSectionTitle('Services & Permissions'),
            _buildSwitchTile(
              title: 'Enable Location Services',
              subtitle: 'Allow Glotune to access your device location',
              value: controller.enableLocationServices,
              onChanged: controller.toggleLocationServices,
            ),
            _buildSwitchTile(
              title: 'Use Precise Location',
              subtitle: 'Use GPS for exact location tracking',
              value: controller.usePreciseLocation,
              onChanged: controller.togglePreciseLocation,
            ),

            // SizedBox(height: 24.h),

            // _buildSectionTitle('Privacy'),
            // _buildSwitchTile(
            //   title: 'Share with Merchants & Creators',
            //   subtitle: 'Allow local businesses and creators to find you',
            //   value: controller.shareLocationWithMerchants,
            //   onChanged: controller.toggleShareLocation,
            // ),
            SizedBox(height: 24.h),

            _buildSectionTitle('Region'),
            _buildDropdownTile(),
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
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
        ),
        value: value.value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your primary region manually if location services are disabled.',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(
              () => DropdownButton<String>(
                value: controller.selectedRegion.value,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                items: controller.regions.map((String region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(
                      region,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedRegion.value = newValue;
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
