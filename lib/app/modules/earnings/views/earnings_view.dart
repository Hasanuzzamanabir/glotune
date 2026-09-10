import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/earnings_controller.dart';
import 'earning_details_view.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final numberFormat = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Earnings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Container(height: 4.h, color: const Color(0xFFF5F5F5)),
          // Balance Section
          Container(
            padding: EdgeInsets.all(20.w),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Total earnings',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.visibility_off,
                      color: Colors.black54,
                      size: 16.sp,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        currencyFormat.format(controller.totalEarnings.value),
                        style: TextStyle(
                          color: const Color(0xFF001F3F), // Very dark blue
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                      size: 20.sp,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 140.w,
                  child: ElevatedButton(
                    onPressed: () => _showMediumOfTransaction(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 8.h, color: const Color(0xFFF5F5F5)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Text(
                      'Recent earning history',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentEarnings.length,
                      itemBuilder: (context, index) {
                        final item = controller.recentEarnings[index];
                        return _buildEarningItem(
                          item['category'] as String,
                          item['amount'] as double,
                          item['time'] as String,
                          item['status'] as String,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(
    String category,
    double amount,
    String time,
    String status,
  ) {
    final numberFormat = NumberFormat.decimalPattern();

    return InkWell(
      onTap: () {
        if (controller.earningDetails.containsKey(category)) {
          Get.to(
            () => EarningDetailsView(
              title: category,
              sections: controller.earningDetails[category] ?? [],
            ),
          );
        } else {
          Get.snackbar('Notice', 'No details available for $category');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_download_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: const Color(0xFF2C3E50),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${numberFormat.format(amount.toInt())}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (status == 'Pending')
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Pending',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMediumOfTransaction() {
    Get.bottomSheet(
      _buildBaseBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetItem(
              icon: Icons.storefront_outlined,
              title: 'Select a medium',
              onTap: () {
                Get.back();
                _showSelectAMedium();
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.credit_card_outlined,
              title: 'Link bank card',
              onTap: () {
                Get.back();
                _showLinkCard();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  void _showSelectAMedium() {
    final providers = [
      {'name': 'PayPal', 'icon': Icons.account_balance_wallet_outlined},
      {'name': 'Stripe', 'icon': Icons.payments_outlined},
      {'name': 'PayU', 'icon': Icons.payment_outlined},
      {'name': 'Mercado Pago', 'icon': Icons.shopping_bag_outlined},
      {'name': 'Alipay', 'icon': Icons.qr_code_scanner_outlined},
      {'name': 'Paytm', 'icon': Icons.account_balance_outlined},
      {'name': 'Gcash', 'icon': Icons.mobile_friendly_outlined},
      {'name': 'Mobile money', 'icon': Icons.phone_android_outlined},
    ];

    Get.bottomSheet(
      _buildBaseBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: providers
              .map(
                (p) => _buildBottomSheetItem(
                  icon: p['icon'] as IconData,
                  title: p['name'] as String,
                  onTap: () {
                    Get.back();
                    // Trigger external WebView/OAuth
                  },
                ),
              )
              .toList(),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  void _showLinkCard() {
    Get.bottomSheet(
      _buildBaseBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetItem(
              icon: Icons.credit_card_outlined,
              title: 'Visa card',
              onTap: () {
                Get.back();
                // Trigger Card Input Form
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.credit_card_outlined,
              title: 'Master card',
              onTap: () {
                Get.back();
                // Trigger Card Input Form
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  Widget _buildBaseBottomSheet({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          child,
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
