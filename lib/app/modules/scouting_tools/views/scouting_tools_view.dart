import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/scouting_tools_controller.dart';

class ScoutingToolsView extends GetView<ScoutingToolsController> {
  const ScoutingToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            "Scouting tools",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 12.w,
                  top: 12.h,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 8.sp),
                  ),
                ),
              ],
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
              Tab(text: "Proposal from managers"),
              Tab(text: "Glotune"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildProposalsTab(), _buildGlotuneTab()]),
      ),
    );
  }

  Widget _buildProposalsTab() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildProposalCard(
            budget: "\$500",
            title: "Rising Star Campaign for AfroBeat Artist",
            targetCreator: "@SoundBlaze",
            genre: "K POP",
            duration: "2 weeks",
            imageIndex: 1,
          ),
          SizedBox(height: 16.h),
          _buildProposalCard(
            budget: "\$1500",
            title: "Rising Star Campaign for AfroBeat Artist",
            targetCreator: "@SoundBlaze",
            genre: "K POP",
            duration: "2 weeks",
            imageIndex: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard({
    required String budget,
    required String title,
    required String targetCreator,
    required String genre,
    required String duration,
    required int imageIndex,
  }) {
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
                      backgroundImage: CachedNetworkImageProvider(
                        "https://picsum.photos/100/100?random=$imageIndex",
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Cameron Williamson",
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
                          "@camwils34",
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
                      budget,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      "Budget",
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
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Target Creator",
                        style: TextStyle(
                          color: Colors.blueGrey[300],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        targetCreator,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Genre",
                        style: TextStyle(
                          color: Colors.blueGrey[300],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        genre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Duration",
                        style: TextStyle(
                          color: Colors.blueGrey[300],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        duration,
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
            width: 40.w,
            height: 40.w,
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "View",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1D1D),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "Download",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
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
