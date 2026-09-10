import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/donations_controller.dart';

class DonationsView extends GetView<DonationsController> {
  const DonationsView({super.key});

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
          'Donations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => Get.toNamed('/make-donation'), // Directly use the route string or import Routes
          ),
        ],
      ),
      body: Obx(() => ListView(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            children: controller.donations.entries.map((entry) {
              return _buildDonationCard(entry.key, entry.value);
            }).toList(),
          )),
    );
  }

  Widget _buildDonationCard(String title, List<dynamic> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildDonationRow(items[index] as Map<String, dynamic>, title);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonationRow(Map<String, dynamic> item, String type) {
    bool isCurrency = type == 'Live Gift' || type == 'Tips';
    String amountPrefix = isCurrency ? '\$' : '';
    
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender Section
          Expanded(
            child: _buildUserColumn(
              "Sender",
              item['sender'],
              amountPrefix + item['amount'].toString(),
              item['date'],
              item['time'],
              true,
            ),
          ),
          SizedBox(width: 12.w),
          // Receiver Section
          Expanded(
            child: _buildUserColumn(
              "Receiver",
              item['receiver'],
              amountPrefix + item['amount'].toString(),
              item['date'],
              item['time'],
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserColumn(
    String role,
    Map<String, dynamic> user,
    String amount,
    String date,
    String time,
    bool isSender,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.5),
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 14.r,
              backgroundImage: AssetImage(user['avatar']),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user['name'],
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
