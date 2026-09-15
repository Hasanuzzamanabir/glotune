import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/premium_sub_reselling_controller.dart';

class PremiumSubResellingView extends GetView<PremiumSubResellingController> {
  const PremiumSubResellingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Premium Subscription Reselling',
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
        // actions: [
        //   Builder(
        //     builder: (context) => IconButton(
        //       icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
        //       onPressed: () => Scaffold.of(context).openDrawer(),
        //     ),
        //   ),
        // ],
      ),
      // drawer: Drawer(
      //   child: Scaffold(
      //     backgroundColor: Colors.white,
      //     appBar: AppBar(
      //       backgroundColor: AppColors.primary,
      //       elevation: 0,
      //       leading: IconButton(
      //         icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
      //         onPressed: () => Get.back(),
      //       ),
      //       title: Text(
      //         'Premium Subscription Reselling',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontSize: 14.sp,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //       titleSpacing: 0,
      //     ),
      //     body: Container(
      //       color: Colors.white,
      //       // Add your drawer items here in the future
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Info Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Info',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoRow(
                    'Subscription Plan Type',
                    'Enterprise Tier 3',
                    isBold: true,
                  ),
                  _buildInfoRow('Total Slot Purchased', '80'),
                  _buildInfoRow('Slot Used', '50'),
                  _buildInfoRow('Slot Available', '30'),
                  _buildInfoRow(
                    'Reselling Price Per Slot',
                    '\$6.25/month',
                    isBold: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Generate Invitation Link Row
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Generate Invitation link',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 8.w,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '@sam483entertier3',
                      style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Send invitation link to
            Text(
              'Send invitation link to',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundImage: const CachedNetworkImageProvider(
                      'https://i.pravatar.cc/150?img=11',
                    ), // Mock avatar
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '@dan2749',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Reselling Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reselling Options',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      Obx(
                        () => GestureDetector(
                          onTap: () => controller.isFree.value = true,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: controller.isFree.value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Text(
                              'Free',
                              style: TextStyle(
                                color: controller.isFree.value
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12.sp,
                                fontWeight: controller.isFree.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => GestureDetector(
                          onTap: () => controller.isFree.value = false,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: !controller.isFree.value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Text(
                              'Payable',
                              style: TextStyle(
                                color: !controller.isFree.value
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12.sp,
                                fontWeight: !controller.isFree.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Confirm reselling date
            Text(
              'Confirm reselling date',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 32.h),

            // Set link expiration date
            Text(
              'Set link expiration date',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 48.h),

            // Bottom Buttons
            Row(
              children: [
                Expanded(child: _buildOutlineButton('Edit', () {})),
                SizedBox(width: 12.w),
                Expanded(child: _buildOutlineButton('Save', () {})),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildOutlineButton('Preview', () {
                    Get.toNamed('/premium-subscription-invitation');
                  }),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  'Publish',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () {
                  Get.toNamed(Routes.RESELLING_ANALYTICS);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  'View Reselling Analytics',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
