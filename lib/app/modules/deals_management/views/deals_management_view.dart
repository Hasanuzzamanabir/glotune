import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/deals_management_controller.dart';

class DealsManagementView extends GetView<DealsManagementController> {
  const DealsManagementView({super.key});

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
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            SizedBox(height: 24.h),
            Text(
              "Creators Table",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            _buildCreatorsTable(),
            SizedBox(height: 80.h), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.CREATE_DEAL),
        backgroundColor: const Color(0xFF8B1D1D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(icon: Icons.computer, title: "Creators Managed", value: "20"),
        _buildStatCard(icon: Icons.call_split, title: "Active Deals", value: "8"),
        _buildStatCard(icon: Icons.request_quote, title: "Pending Proposals", value: "12"),
        _buildStatCard(icon: Icons.campaign, title: "ROI Across Creators", value: "55%"),
      ],
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF8B1D1D), size: 24.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                Expanded(flex: 2, child: Text("Creator Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                Expanded(flex: 1, child: Text("Active Deals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
                Expanded(flex: 1, child: Text("Total Deal Value", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp))),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          _buildTableRow(creator: "@JaneVisuals", deals: "3", value: "\$15,000"),
          _buildTableRow(creator: "@BeatsByTino", deals: "2", value: "\$9,500"),
          _buildTableRow(creator: "@poe", deals: "6", value: "\$150,000"),
        ],
      ),
    );
  }

  Widget _buildTableRow({required String creator, required String deals, required String value}) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.CREATOR_DEALS),
      child: Container(
        color: Colors.transparent, // to make the row tapable
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 2, child: Text(creator, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
                  Expanded(flex: 1, child: Text(deals, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
                  Expanded(flex: 1, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
