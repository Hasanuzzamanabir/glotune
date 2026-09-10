import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/order_management_controller.dart';
import 'package:glotune/app/routes/app_pages.dart';

class OrderManagementView extends GetView<OrderManagementController> {
  const OrderManagementView({super.key});

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
          'Order management',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey[50], // Light grey background for stats section
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_offer_rounded,
                          title: 'Pending Orders',
                          value: '1200',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.inventory_2_rounded,
                          title: 'Returns',
                          value: '120',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.notifications_active_rounded,
                          title: 'Shipped',
                          value: '100',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(child: SizedBox()), // Empty space to match grid layout
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Table',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.ORDER_LIST),
                        child: Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(8.r),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: Colors.red[800], size: 20.sp),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
              'Buyer',
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
          Expanded(
            flex: 4,
            child: Text(
              'Status',
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Row(
          children: [
            Expanded(
              flex: 3,
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
                data['buyer']!,
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
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _buildStatusPill(data['status']!),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  Widget _buildStatusPill(String status) {
    bool isCompleted = status.toLowerCase() == 'completed';
    Color color = isCompleted ? Colors.green : Colors.orange;
    Color bgColor = isCompleted ? Colors.green[50]! : Colors.orange[50]!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8.sp),
          SizedBox(width: 4.w),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
