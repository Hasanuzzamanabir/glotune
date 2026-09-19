import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/data/models/campaign.dart';
import '../controllers/campaign_management_controller.dart';

class CampaignManagementView extends GetView<CampaignManagementController> {
  const CampaignManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Campaign management',
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
              color: Colors.grey[50],
              padding: EdgeInsets.all(16.w),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    icon: Icons.local_offer_rounded,
                    title: 'Active Campaign',
                    value: '1200',
                  ),
                  _buildStatCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'Total Budget',
                    value: '\$10,000',
                  ),
                  _buildStatCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Average ROI',
                    value: '20%',
                  ),
                  _buildStatCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Conversions',
                    value: '200',
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
                  Text(
                    'Campaign Table',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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
                        Obx(() {
                          if (controller.isCampaignsLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (controller.campaignList.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(child: Text("No campaigns found")),
                            );
                          }
                          return Column(
                            children: controller.campaignList
                                .asMap()
                                .entries
                                .map((entry) {
                                  int index = entry.key;
                                  final campaign = entry.value;
                                  return Column(
                                    children: [
                                      _buildTableRow(campaign),
                                      if (index !=
                                          controller.campaignList.length - 1)
                                        Divider(
                                          height: 1,
                                          color: Colors.grey[200],
                                        ),
                                    ],
                                  );
                                })
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 60.h), // padding for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.CREATE_NEW_CAMPAIGN),
        backgroundColor: const Color(0xFF8B1D1D),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
          Spacer(),
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
            flex: 2,
            child: Text(
              'Campaign Name',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Type',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Managed by',
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

  Widget _buildTableRow(Campaign data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              data.title,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              data.campaignType,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              data.creatorName ?? 'Unknown',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
