import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/premium_subscription_controller.dart';

class PremiumSubscriptionView extends GetView<PremiumSubscriptionController> {
  const PremiumSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Light grayish background
      appBar: AppBar(
        title: Text(
          'GloTune Premium Subscription',
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
            _buildPlanCard(
              title: 'BASIC PLAN',
              price: 'US\$6.99/month',
              perks: [
                'i. Ads-free viewing',
                'ii. Background play',
                'iii. Access to exclusive content',
              ],
              buttonText: 'Subscribe \$6.99',
            ),
            SizedBox(height: 20.h),
            
            _buildPlanCard(
              title: 'PRO PLAN',
              price: 'US\$14.99/month',
              perks: [
                'i. All basic plan perk',
                'ii. Offline downloads',
                'iii. Up to 6 users',
              ],
              buttonText: 'Subscribe \$14.99',
            ),
            SizedBox(height: 20.h),
            
            _buildEnterprisePlanCard(),
            
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/premium-subscription-invitation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  'Receiving Reselling Invitations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
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
                onPressed: () => Get.toNamed('/premium-sub-reselling'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  'Reselling Details & Overview',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Column(
              children: [
                Text(
                  'Thanks for your subscription',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B), // Dark slate
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Enjoy the best on GloTune',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
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

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> perks,
    required String buttonText,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 2)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          // Body
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
                SizedBox(height: 4.h),
                Text(
                  price,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 16.h),
                ...perks.map((perk) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    perk,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                )),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterprisePlanCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 2)),
            ),
            child: Text(
              'ENTERPRISE PLAN',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          // Body
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnterpriseTier(
                  tier: 'Tier One',
                  perks: ['i. All pro plan perks', 'ii. Up to 15 users'],
                  price: '\$29.99',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: Colors.grey[100], thickness: 1),
                ),
                _buildEnterpriseTier(
                  tier: 'Tier Two',
                  perks: ['i. All tier one perks', 'ii. Up to 30 users'],
                  price: '\$49.99',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: Colors.grey[100], thickness: 1),
                ),
                _buildEnterpriseTier(
                  tier: 'Tier Three',
                  perks: ['i. All tier two perks', 'ii. Up to 80 users'],
                  price: '\$99.99',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterpriseTier({
    required String tier,
    required List<String> perks,
    required String price,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  tier,
                  style: TextStyle(color: Colors.red[300], fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12.h),
              ...perks.map((perk) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  perk,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              )),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Text(
              price,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 32.h,
              width: 100.w,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Subscribe',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
