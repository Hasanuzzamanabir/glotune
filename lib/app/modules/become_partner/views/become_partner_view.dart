import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/become_partner_controller.dart';
import 'become_partner_step2_view.dart';

class BecomePartnerView extends GetView<BecomePartnerController> {
  const BecomePartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          'Become a Partner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar row
            Row(
              children: [
                Icon(Icons.arrow_back_ios, size: 16.sp, color: Colors.black87),
                SizedBox(width: 8.w),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Container(
                        height: 4.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partner Organizer\'s Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tell us about your company or institution to help us understand your capacity to organize',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Upload Logo
            Center(
              child: Column(
                children: [
                  Container(
                    height: 80.w,
                    width: 80.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.camera_alt,
                      color: const Color(0xFF8B1A10),
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Upload Logo of institution',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Form Fields
            _buildTextField('Name of institution or company'),
            SizedBox(height: 16.h),
            
            _buildTextField('Scope of business'),
            SizedBox(height: 16.h),
            
            _buildDropdownField('Country of operations'),
            SizedBox(height: 16.h),
            
            _buildTextField('Business Email'),
            SizedBox(height: 16.h),
            
            _buildTextField('Business address and location', maxLines: 3),
            SizedBox(height: 16.h),
            
            _buildTextField('Official GloTune account of the institution'),
            SizedBox(height: 32.h),
            
            // Next Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const BecomePartnerStep2View()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A10), // Deep red
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0,
                ),
                child: Text(
                  'Next',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: maxLines > 1 ? 16.h : 18.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: const [],
          onChanged: (value) {},
        ),
      ),
    );
  }
}
