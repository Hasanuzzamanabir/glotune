import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/modules/home/views/widgets/video_card.dart';
import '../controllers/my_channel_controller.dart';

class MyChannelView extends GetView<MyChannelController> {
  const MyChannelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Image.asset('assets/images/logo.png', height: 24.h),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.cast, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          // Content Filters
          _buildContentFilters(),
          
          // Content Grid/List
          Expanded(
            child: Obx(() {
              if (controller.selectedFilter.value == "Shorts") return _buildShortsGrid();
              return _buildVideosList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentFilters() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: controller.filters.map((filter) => _buildFilterItem(filter)).toList(),
      ),
    );
  }

  Widget _buildFilterItem(String filter) {
    return Obx(() {
      bool isSelected = controller.selectedFilter.value == filter;
      return GestureDetector(
        onTap: () => controller.setFilter(filter),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            filter,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12.sp,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShortsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: const DecorationImage(image: AssetImage('assets/images/video_thumb_1.png'), fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 8.h,
                left: 8.w,
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                    Text("1.5M views", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideosList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return VideoCard(
          title: "LOVE IN EVERY NOOK AND CRANE IN 20125",
          creator: "Ladies First Channel",
          views: "2.5K views",
          time: "4h ago",
          duration: "30:56",
          thumbnailUrl: "assets/images/video_thumb_2.png",
          creatorAvatarUrl: "assets/images/user_avatar.png",
          onMorePressed: () {},
        );
      },
    );
  }
}
