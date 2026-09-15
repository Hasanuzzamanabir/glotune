import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/ads_campaign_controller.dart';
import 'create_ads_campaign_step1_view.dart';

class AdsCampaignView extends GetView<AdsCampaignController> {
  const AdsCampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ads Campaign',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const CreateAdsCampaignStep1View()),
              icon: Icon(Icons.add, size: 16.sp, color: Colors.white),
              label: Text(
                'Add Campaign',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ads Campaign Management',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),

              // Campaign Management Table
              _buildCampaignTable(),

              SizedBox(height: 32.h),

              // Notifications and Exports (Stacked for mobile)
              _buildNotificationsCard(),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(child: _buildExportButton('Export as CSV')),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildExportButton('Export as PDF')),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
        child: Obx(() {
          if (controller.isCampaignsLoading.value) {
            return Container(
              height: 100.h,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.campaignList.isEmpty) {
            return Container(
              height: 100.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Text("No campaigns found"),
            );
          }
          return DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
            columnSpacing: 24.w,
            dataRowMaxHeight: 50.h,
            dataRowMinHeight: 40.h,
            columns: const [
              DataColumn(
                label: Text(
                  'SN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Campaign Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Campaign ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Impression',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'CTR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Conversions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Cost',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Revenue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'ROI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: controller.campaignList.asMap().entries.map((entry) {
              final index = entry.key;
              final campaign = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(campaign.title)),
                  DataCell(Text(campaign.id.toString())),
                  DataCell(Text(campaign.campaignType)),
                  DataCell(
                    Text(campaign.analytics?.impressions.toString() ?? '0'),
                  ),
                  DataCell(Text(campaign.analytics?.ctr ?? '0%')),
                  DataCell(
                    Text(campaign.analytics?.conversions.toString() ?? '0'),
                  ),
                  DataCell(Text('\$${campaign.campaignCost}')),
                  DataCell(Text('\$${campaign.analytics?.revenue ?? '0'}')),
                  DataCell(Text(campaign.analytics?.roi ?? '0%')),
                  DataCell(_buildStatusPill(campaign.campaignStatus)),
                ],
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color;
    IconData icon;
    if (status == 'Active') {
      color = Colors.green;
      icon = Icons.circle;
    } else if (status == 'Completed') {
      color = Colors.red;
      icon = Icons.circle;
    } else {
      color = Colors.orange;
      icon = Icons.circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 8.sp),
          SizedBox(width: 4.w),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications & Alerts',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          _buildNotificationItem(
            'Notify when budget is 80% or 100% spent',
            true,
          ),
          _buildNotificationItem(
            'Alert when click through rate crosses 5%',
            false,
          ),
          _buildNotificationItem(
            'Alert when paused, completed or rejected',
            true,
          ),
          _buildNotificationItem(
            'Notify for failed or pending payments',
            false,
          ),
          _buildNotificationItem(
            'Notify when invoice is ready for download',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String text, bool active) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.check_circle_outline,
            color: active ? Colors.green : Colors.grey[400],
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
