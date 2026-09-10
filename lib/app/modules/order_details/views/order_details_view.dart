import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 20.h,
              color: Colors.grey[50], // Very light padding
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  _buildExpandableSection(
                    title: "Buyer's Details",
                    initiallyExpanded: true,
                    content: Column(
                      children: [
                        _buildDetailRow('Name', 'Jane Doe'),
                        SizedBox(height: 12.h),
                        _buildDetailRow('Email address', 'janedoe@email.com'),
                        SizedBox(height: 12.h),
                        _buildDetailRow('Phone number', '+1234567890'),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildExpandableSection(
                    title: "Creator's Info",
                    content: const SizedBox(),
                  ),
                  SizedBox(height: 12.h),
                  _buildExpandableSection(
                    title: "Items Ordered",
                    content: const SizedBox(),
                  ),
                  SizedBox(height: 12.h),
                  _buildExpandableSection(
                    title: "Payment summary",
                    content: const SizedBox(),
                  ),
                  SizedBox(height: 12.h),
                  _buildExpandableSection(
                    title: "Shipping Details",
                    content: const SizedBox(),
                  ),
                  SizedBox(height: 12.h),
                  _buildExpandableSection(
                    title: "Tracking",
                    content: const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          childrenPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h, top: 4.h),
          expandedAlignment: Alignment.centerLeft,
          children: [
            if (content is! SizedBox)
              Divider(height: 1, color: Colors.grey[200]),
            if (content is! SizedBox)
              SizedBox(height: 16.h),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
