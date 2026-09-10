import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/performance_log_controller.dart';

class PerformanceLogView extends GetView<PerformanceLogController> {
  const PerformanceLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1D1D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Video Performance",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Video Performance",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  return DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.transparent),
                    dataRowMinHeight: 60.h,
                    dataRowMaxHeight: 60.h,
                    horizontalMargin: 12.w,
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
                    columns: const [
                      DataColumn(label: Text("Video Title", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Views", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Watch Time", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Likes", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Engagement Rate", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Shares", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Earnings", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: controller.performances.map((perf) {
                      return DataRow(
                        cells: [
                          DataCell(Text(perf.videoTitle)),
                          DataCell(Text(perf.views)),
                          DataCell(Text(perf.watchTime)),
                          DataCell(Text(perf.likes)),
                          DataCell(Text(perf.comments)),
                          DataCell(Text(perf.engagementRate)),
                          DataCell(Text(perf.shares)),
                          DataCell(Text(perf.earnings)),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
