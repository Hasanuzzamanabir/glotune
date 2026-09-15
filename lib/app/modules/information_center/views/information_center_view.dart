import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/information_center_controller.dart';

class InformationCenterView extends GetView<InformationCenterController> {
  const InformationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Information center",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.assignment_outlined,
                color: Colors.black,
                size: 24.sp,
              ),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: const Color(0xFF8B1D1D),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF8B1D1D),
            indicatorWeight: 3.h,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 13.sp),
            tabs: const [
              Tab(text: "Talent managers"),
              Tab(text: "Merchants"),
              Tab(text: "Glotune"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTalentManagersTab(),
            _buildMerchantsTab(),
            _buildGlotuneTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTalentManagersTab() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.infoData.value;
        if (data == null ||
            (data.userName == null && data.userUsername == null)) {
          return Center(
            child: Text(
              "No proposals available",
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [_buildTalentCard(data)],
        );
      }),
    );
  }

  Widget _buildTalentCard(dynamic data) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PROPOSAL_DETAILS),
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: const CachedNetworkImageProvider(
                        "https://picsum.photos/100/100?random=5",
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.userName ?? "Unknown",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.military_tech,
                              color: Colors.orange,
                              size: 16.sp,
                            ),
                          ],
                        ),
                        Text(
                          data.userUsername ?? "",
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.revenueSharing ?? "N/A",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      "Revenue sharing",
                      style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contract Proposal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Other benefits",
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Expanded(
                        child: Text(
                          data.others ?? "None",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Duration",
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Text(
                        data.duration ?? "N/A",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantsTab() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [_buildMerchantCard()],
      ),
    );
  }

  Widget _buildMerchantCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PROPOSAL_DETAILS),
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: const CachedNetworkImageProvider(
                        "https://picsum.photos/100/100?random=6",
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "ABS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.military_tech,
                              color: Colors.orange,
                              size: 16.sp,
                            ),
                          ],
                        ),
                        Text(
                          "Fashion",
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$500-1000",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      "Budget range",
                      style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sponsored Content",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Platform",
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Text(
                        "Instagram & Glotune",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Duration",
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Text(
                        "Campaign duration",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlotuneTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      children: [
        _buildGlotuneItem("Campaign proposal", "08/05/2025"),
        _buildDivider(),
        _buildGlotuneItem("Talent List", "08/05/2025"),
        _buildDivider(),
        _buildGlotuneItem("Brand Guidelines", "08/05/2025"),
        _buildDivider(),
        _buildGlotuneItem("Promo video", "08/05/2025"),
        _buildDivider(),
      ],
    );
  }

  Widget _buildGlotuneItem(String title, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: Color(0xFF8B1D1D),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blueGrey[400],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1D1D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
            ),
            child: Text(
              "Download",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withValues(alpha: 0.1),
    );
  }
}
