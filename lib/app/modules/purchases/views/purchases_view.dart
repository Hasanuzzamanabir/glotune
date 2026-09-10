import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/purchases_controller.dart';

class PurchasesView extends GetView<PurchasesController> {
  const PurchasesView({super.key});

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
          'Purchases',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPurchaseItem(
                    icon: Icons.subscriptions_rounded,
                    title: 'Membership subscription',
                    value: () => '\$${controller.membershipCost.value}',
                  ),
                  SizedBox(height: 20.h),
                  _buildPurchaseItem(
                    icon: Icons.monetization_on_rounded,
                    title: 'Recharged coins',
                    value: () => '${controller.rechargedCoins.value}',
                  ),
                  SizedBox(height: 20.h),
                  _buildPurchaseItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Purchased Credit',
                    value: () => '${controller.purchasedCredit.value}',
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Buy Coins',
                          color: const Color(0xFFF5F5F5),
                          textColor: Colors.black87,
                          onTap: () => controller.buyCoins(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Buy Credit',
                          color: AppColors.primary,
                          textColor: Colors.white,
                          onTap: () => controller.buyCredit(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseItem({
    required IconData icon,
    required String title,
    required String Function() value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Obx(() => Text(
              value(),
              style: TextStyle(
                color: const Color(0xFF64B5F6), // Light blue value
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            )),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
