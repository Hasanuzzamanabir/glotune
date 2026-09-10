import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/sponsorship_center_controller.dart';

class SponsorshipCenterView extends GetView<SponsorshipCenterController> {
  const SponsorshipCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Sponsorship center",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          bottom: TabBar(
            labelColor: const Color(0xFF8B1D1D),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF8B1D1D),
            indicatorWeight: 3.h,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 13.sp),
            tabs: const [
              Tab(text: "Active sponsors"),
              Tab(text: "Pending sponsors"),
              Tab(text: "Completed sponsors"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSponsorsList(),
            _buildSponsorsList(),
            _buildSponsorsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorsList() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSponsorCard(),
        SizedBox(height: 16.h),
        _buildSponsorCard(),
      ],
    );
  }

  Widget _buildSponsorCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PROPOSAL_DETAILS),
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: const CachedNetworkImageProvider("https://picsum.photos/100/100?random=15"),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pepsi China", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        Text("@camwils34", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("\$1,500", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Text("Budget", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pepsi Sound Nation Tour", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.black87)),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Deadline", style: TextStyle(color: Colors.blueGrey[300], fontSize: 12.sp, fontWeight: FontWeight.w500)),
                      Text("20-05-25", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("For", style: TextStyle(color: Colors.blueGrey[300], fontSize: 12.sp, fontWeight: FontWeight.w500)),
                      Text("Comedians and muscians", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status", style: TextStyle(color: Colors.blueGrey[300], fontSize: 12.sp, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text("Open", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87)),
                        ],
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
}
