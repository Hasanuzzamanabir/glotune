import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/order_list_controller.dart';

import 'package:glotune/app/routes/app_pages.dart';

class OrderListView extends GetView<OrderListController> {
  const OrderListView({super.key});

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
          'Order list',
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
              height: 24.h,
              color: Colors.grey[50], // Very light top padding area
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Column(
                  children: [
                    _buildTableHeader(),
                    Divider(height: 1, color: Colors.grey[200]),
                    ...controller.orderList.map((order) {
                      int index = controller.orderList.indexOf(order);
                      return Column(
                        children: [
                          _buildTableRow(order),
                          if (index != controller.orderList.length - 1)
                            Divider(height: 1, color: Colors.grey[200]),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Order ID',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Creator',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Product',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> data) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.ORDER_DETAILS),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                data['orderId']!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                data['creator']!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                data['product']!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
