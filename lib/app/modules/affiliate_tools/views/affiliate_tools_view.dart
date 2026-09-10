import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/affiliate_tools_controller.dart';

class AffiliateToolsView extends GetView<AffiliateToolsController> {
  const AffiliateToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Affiliate tools",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDivider(),
            _buildSection(
              title: "Your referral links",
              child: Container(
                padding: EdgeInsets.only(left: 16.w, right: 6.w, top: 6.h, bottom: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "vdfDT64I8DGDDKDOLFHFF...",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1D1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        elevation: 0,
                      ),
                      child: Text(
                        "Copy",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDivider(),
            _buildSection(
              title: "Link generator",
              child: _buildOutlinedButton("Generate link", () {}),
            ),
            _buildDivider(),
            _buildSection(
              title: "Promo materials",
              child: _buildVerificationBanner(),
            ),
            _buildDivider(),
            _buildSection(
              title: "QR Code generator",
              child: _buildOutlinedButton("Create QR code", () {}),
            ),
            Container(
              height: 100.h,
              color: const Color(0xFFF9F9F9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 4.h,
      color: const Color(0xFFF9F9F9),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF8B1D1D), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF8B1D1D),
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B00F8),
            Color(0xFFEE8775),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.MANAGER_VERIFICATION),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Complete Your Verification",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      "Verify",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16.sp),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment,
                color: const Color(0xFF7B2CBF),
                size: 28.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
