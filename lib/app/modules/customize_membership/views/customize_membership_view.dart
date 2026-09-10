import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/customize_membership_controller.dart';

class CustomizeMembershipView extends GetView<CustomizeMembershipController> {
  const CustomizeMembershipView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Membership Subscription Customization',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp, // Using a slightly smaller font for long title
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
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Customizing your membership subscription\nplan will replace the default plan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24.h),

            _buildSectionTitle('Select Plan Name'),
            SizedBox(height: 8.h),
            _buildDropdown(),
            SizedBox(height: 12.h),
            _buildAddButton('+ Add a new plan'),

            SizedBox(height: 24.h),

            _buildSectionTitle('Set Price For Each Plan'),
            SizedBox(height: 8.h),
            _buildTextField('\$0.00'),

            SizedBox(height: 24.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Perks for Each Plan'),
                  SizedBox(height: 16.h),
                  Obx(() => Column(
                    children: List.generate(
                      controller.perks.length,
                      (index) => _buildPerkItem(index),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _buildAddButton('+ Add a new perk'),

            SizedBox(height: 24.h),
            
            _buildSectionTitle('Set Availability'),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildAvailabilityToggle(),
                const Spacer(),
                _buildPreviewButton(),
              ],
            ),

            SizedBox(height: 40.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      elevation: 0,
                    ),
                    child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      elevation: 0,
                    ),
                    child: Text('Publish', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            value: controller.selectedPlan.value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
            items: controller.plans.map((String plan) {
              return DropdownMenuItem<String>(
                value: plan,
                child: Text(plan, style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.selectedPlan.value = newValue;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildAddButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.blue, fontSize: 12.sp),
      ),
    );
  }

  Widget _buildPerkItem(int index) {
    final perk = controller.perks[index];
    final isSelected = perk['selected'] as bool;
    
    return GestureDetector(
      onTap: () => controller.togglePerk(index),
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.check_circle,
              color: isSelected ? Colors.green : Colors.grey[300],
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                perk['name'] as String,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Obx(() {
      final isPublic = controller.isPublic.value;
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.setAvailability(true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isPublic ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Public',
                  style: TextStyle(
                    color: isPublic ? Colors.white : Colors.black87,
                    fontSize: 14.sp,
                    fontWeight: isPublic ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => controller.setAvailability(false),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: !isPublic ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Private',
                  style: TextStyle(
                    color: !isPublic ? Colors.white : Colors.black87,
                    fontSize: 14.sp,
                    fontWeight: !isPublic ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPreviewButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        elevation: 0,
      ),
      child: Text(
        'Preview',
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }
}
