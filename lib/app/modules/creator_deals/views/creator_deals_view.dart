import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/creator_deals_controller.dart';

class CreatorDealsView extends GetView<CreatorDealsController> {
  const CreatorDealsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Deals management",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deals for @janevisuals",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDealsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Brand/ Sponsor",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Campaign Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Deal Value",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
          _buildTableRow(
            brand: "BrandX Skincare",
            campaign: "SkinGlow Launch",
            value: "\$15,000",
          ),
          _buildTableRow(
            brand: "GigaSound",
            campaign: "Summer Drops",
            value: "\$9,500",
          ),
          _buildTableRow(
            brand: "TouchVibes",
            campaign: "Mechs",
            value: "\$150,000",
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String brand,
    required String campaign,
    required String value,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  brand,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  campaign,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
      ],
    );
  }
}
