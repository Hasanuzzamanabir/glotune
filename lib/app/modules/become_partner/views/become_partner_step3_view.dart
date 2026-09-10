import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/become_partner_controller.dart';
import 'package:glotune/app/routes/app_pages.dart';

class BecomePartnerStep3View extends GetView<BecomePartnerController> {
  const BecomePartnerStep3View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            _buildCard(
              title: 'Mission',
              titleBgColor: Colors.black,
              titleTextColor: Colors.white,
              cardBgColor: Colors.white,
              borderColor: Colors.grey[300]!,
              child: Text(
                'Glotune seeks to partner and empower organizations to shape the future of content by hosting impactful competitions, talent hunts, and entertainment campaigns that inspire creativity and community',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4),
              ),
            ),
            SizedBox(height: 24.h),
            
            _buildCard(
              title: 'Benefits',
              titleBgColor: Colors.white,
              titleTextColor: Colors.black87,
              cardBgColor: const Color(0xFFF8F9FA),
              borderColor: Colors.grey[200]!,
              titleBorderColor: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBenefitItem('Amplify your brand visibility'),
                  SizedBox(height: 8.h),
                  _buildBenefitItem('Engage with Glotune\'s creator community'),
                  SizedBox(height: 8.h),
                  _buildBenefitItem('Build long term influence through collaboration'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            _buildCard(
              title: 'Campaign Types',
              titleBgColor: Colors.white,
              titleTextColor: Colors.black87,
              cardBgColor: const Color(0xFFFFF7F7), // Light reddish-pink
              borderColor: const Color(0xFFFFF7F7),
              titleBorderColor: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNumberedItem('1', 'Creators battle to the Top'),
                  _buildNumberedItem('2', 'Comedy talent shows'),
                  _buildNumberedItem('3', 'Music competition'),
                  _buildNumberedItem('4', 'Dance competition'),
                  _buildNumberedItem('5', 'Educational contest'),
                  _buildNumberedItem('6', 'Cause driven debate'),
                  _buildNumberedItem('7', 'Branded content series'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            _buildCard(
              title: 'Subscription',
              titleBgColor: Colors.black,
              titleTextColor: Colors.white,
              cardBgColor: Colors.white,
              borderColor: Colors.grey[300]!,
              child: Text(
                'All partner organizations should sign up for one of the Enterprise Plan Tiers of the GloTune Premium Subscription.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4),
              ),
            ),
            SizedBox(height: 40.h),
            
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () {
                  // Assuming they want to go to the premium subscription page when clicking this
                  Get.toNamed(Routes.PREMIUM_SUBSCRIPTION);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A10), // Deep red
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  elevation: 0,
                ),
                child: Text(
                  'See the Enterprises Premium\nSubscription Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color titleBgColor,
    required Color titleTextColor,
    required Color cardBgColor,
    required Color borderColor,
    Color? titleBorderColor,
    required Widget child,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: EdgeInsets.only(top: 14.h),
          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: titleBgColor,
              borderRadius: BorderRadius.circular(20.r),
              border: titleBorderColor != null ? Border.all(color: titleBorderColor) : null,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: titleTextColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 16.sp, color: Colors.black87),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 16.w,
            child: Text(
              '$number.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.3),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
