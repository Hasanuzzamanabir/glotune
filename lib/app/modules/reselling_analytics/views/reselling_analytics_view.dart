import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/reselling_analytics_controller.dart';

class ResellingAnalyticsView extends GetView<ResellingAnalyticsController> {
  const ResellingAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Matches the background behind the white container
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resold Premium Subscription Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(),
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.analyticsData.map((data) {
                          return _buildDataGroup(data);
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Column widths
  final double _wPeriod = 100;
  final double _wSN = 60;
  final double _wSlots = 120;
  final double _wPlan = 140;
  final double _wStatus = 120;
  final double _wDate = 140;
  final double _wAction = 100;

  Widget _buildHeaderRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Row(
        children: [
          _buildCell('Period', _wPeriod, isHeader: true),
          _buildCell('SN', _wSN, isHeader: true),
          _buildCell('Active Slots', _wSlots, isHeader: true),
          _buildCell('Plan Type', _wPlan, isHeader: true),
          _buildCell('Payment Status', _wStatus, isHeader: true),
          _buildCell('Payment Due Date', _wDate, isHeader: true),
          _buildCell('Action', _wAction, isHeader: true, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDataGroup(Map<String, dynamic> data) {
    List<Map<String, String>> records = data['records'];
    String period = data['period'];

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Cell (Spans multiple rows)
            Container(
              width: _wPeriod,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey[400]!)),
              ),
              child: Text(
                period,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // The records column
            Column(
              children: records.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> record = entry.value;
                bool isLastRow = index == records.length - 1;

                return Container(
                  decoration: BoxDecoration(
                    border: isLastRow ? null : Border(bottom: BorderSide(color: Colors.grey[400]!)),
                  ),
                  child: Row(
                    children: [
                      _buildCell(record['sn']!, _wSN),
                      _buildCell(record['slots']!, _wSlots),
                      _buildCell(record['plan']!, _wPlan),
                      _buildCell(record['status']!, _wStatus),
                      _buildCell(record['date']!, _wDate),
                      _buildActionCell(period, record['slots']!, _wAction),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String text, double width, {bool isHeader = false, bool isLast = false}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: isLast ? null : Border(right: BorderSide(color: Colors.grey[400]!)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActionCell(String period, String username, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          controller.revokeAccess(period.replaceAll('\n', ' '), username);
        },
        child: Text(
          'Revoke Now',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Or AppColors.primary if you want it to stand out
          ),
        ),
      ),
    );
  }
}
