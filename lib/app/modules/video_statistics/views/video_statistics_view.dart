import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/video_statistics_controller.dart';

class VideoStatisticsView extends GetView<VideoStatisticsController> {
  const VideoStatisticsView({super.key});

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
          "Video statistics",
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
              final data = controller.statistics.value;
              if (data == null) {
                return Container(
                  height: 320.h,
                  alignment: Alignment.center,
                  child: const Text("No video statistics available"),
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
                    _buildStatCard(
                      Icons.monitor_outlined,
                      "Total views",
                      data.totalViews.toString(),
                    ),
                    _buildStatCard(
                      Icons.account_balance_wallet_outlined,
                      "Average Engagement",
                      data.averageEngagement,
                    ),
                    _buildStatCard(
                      Icons.hub_outlined,
                      "Total Watch Time",
                      "${data.totalWatchTime} hrs",
                    ),
                    _buildStatCard(
                      Icons.campaign_outlined,
                      "Total Earnings",
                      "\$${data.totalEarnings}",
                    ),
                    _buildStatCard(
                      Icons.trending_up,
                      "Shares",
                      data.totalShared.toString(),
                    ),
                    _buildStatCard(
                      Icons.thumb_up_alt_outlined,
                      "Total Likes",
                      data.totalLikes.toString(),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 24.h),

            // Detailed Table Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "Video Performance Table",
                style: TextStyle(
                  fontSize: 16.sp,
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
                  final data = controller.statistics.value;
                  if (data == null || data.performanceTable.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("No detailed performance available"),
                    );
                  }
                  return DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    dataRowMinHeight: 65.h,
                    dataRowMaxHeight: 65.h,
                    horizontalMargin: 16.w,
                    columnSpacing: 30.w,
                    dividerThickness: 1,
                    border: TableBorder(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      left: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      right: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      horizontalInside: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      verticalInside: BorderSide.none,
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          "Video Title",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Views",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Likes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Shares",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                    rows: data.performanceTable.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 100.w,
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.blueGrey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${item.views}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${item.likes}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${item.shares}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
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
            color: Colors.black.withValues(alpha: 0.02),
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
              color: const Color(0xFF8B1D1D).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: const Color(0xFF8B1D1D), size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.blueGrey[400]),
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
