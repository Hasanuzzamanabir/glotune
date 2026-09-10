import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/performance_metrics_controller.dart';

class PerformanceMetricsView extends GetView<PerformanceMetricsController> {
  const PerformanceMetricsView({super.key});

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
          "Performance metrics",
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
            // Top Gray Area with Scrolling Grid
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 320.h,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }
              final data = controller.metrics.value;
              if (data == null) {
                return Container(
                  height: 320.h,
                  alignment: Alignment.center,
                  child: const Text("No performance metrics available"),
                );
              }

              return Container(
                width: double.infinity,
                height: 320.h,
                color: const Color(0xFFF9F9F9),
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: GridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.w,
                  crossAxisSpacing: 16.h,
                  childAspectRatio: 0.65,
                  children: [
                    _buildStatCard(Icons.monitor_outlined, "Clicks", data.totalClicks.toString()),
                    _buildStatCard(Icons.account_balance_wallet_outlined, "Commission Earned", "\$${data.commissionEarned}"),
                    _buildStatCard(Icons.hub_outlined, "Conversions", data.totalConversions),
                    _buildStatCard(Icons.campaign_outlined, "Earnings Per Click", "\$${data.earningPerClicks}"),
                    _buildStatCard(Icons.trending_up, "CTR", "${data.ctr}%"),
                    _buildStatCard(Icons.payments_outlined, "Total Payout", "\$${data.totalPayouts}"),
                  ],
                ),
              );
            }),
            
            SizedBox(height: 24.h),
            
            // Detailed Table Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "Detailed Table",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final data = controller.metrics.value;
                  if (data == null || data.detailsTable.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("No details available"),
                    );
                  }
                  return DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.transparent),
                    dataRowMinHeight: 65.h,
                    dataRowMaxHeight: 65.h,
                    horizontalMargin: 16.w,
                    columnSpacing: 30.w,
                    dividerThickness: 1,
                    border: TableBorder(
                      top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      left: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      horizontalInside: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      verticalInside: BorderSide.none,
                    ),
                    columns: [
                      DataColumn(label: Text("S/N", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                      DataColumn(label: Text("Campaign", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                      DataColumn(label: Text("Clicks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                      DataColumn(label: Text("Conversions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                      DataColumn(label: Text("Commission", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                    ],
                    rows: data.detailsTable.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text("${index + 1}", style: TextStyle(fontSize: 14.sp))),
                          DataCell(Text(item.title, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                          DataCell(Text("${item.clicks}", style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                          DataCell(Text("${item.conversions}", style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                          DataCell(Text("\$${item.commissionEarned}", style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8B1D1D).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: const Color(0xFF8B1D1D), size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.blueGrey[400],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
