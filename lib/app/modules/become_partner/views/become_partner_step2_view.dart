import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/become_partner_controller.dart';
import 'become_partner_step3_view.dart';

class BecomePartnerStep2View extends GetView<BecomePartnerController> {
  const BecomePartnerStep2View({super.key});

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
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.arrow_back_ios, size: 16.sp, color: Colors.black87),
                ),
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
                        width: 120.w, // Longer progress line
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
                    'Event Duration',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Define the timeframe you wish to hold the event rights for. Duration of Event Organization Rights is yearly (From year - To year)',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Form Fields
            _buildDateField('From year'),
            SizedBox(height: 16.h),
            _buildDateField('To year'),
            
            SizedBox(height: 40.h),
            
            // Next Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const BecomePartnerStep3View()),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        readOnly: true, // Typically date fields are read-only and open a picker
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(Icons.calendar_today_outlined, color: const Color(0xFF8B1A10), size: 20.sp),
        ),
      ),
    );
  }
}
