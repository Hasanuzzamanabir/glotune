import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/modules/home/views/widgets/video_card.dart';
import 'package:glotune/app/modules/subscriptions/views/subscriptions_view.dart';
import '../controllers/creator_channel_controller.dart';

class CreatorChannelView extends GetView<CreatorChannelController> {
  const CreatorChannelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Subscription',
          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Channel Header
            _buildChannelHeader(),
            
            // Subscribed Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text(
                    'Subscribed',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // Content Filters
            _buildContentFilters(),
            
            // Video List
            _buildVideoList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundImage: AssetImage(controller.creatorData['avatar']!),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.creatorData['name']!,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${controller.creatorData['subs']} Subscribers • ${controller.creatorData['videos']} Videos',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'I am a sole and major analyst of the financial market. I share my views and perspective about the financial expectations...',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContentFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() => Row(
        children: controller.filters.map((filter) {
          bool isSelected = controller.selectedFilter.value == filter;
          return GestureDetector(
            onTap: () => controller.setFilter(filter),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return VideoCard(
          title: "Why it's never too late to start",
          creator: "Shawn Entertainment",
          views: "1M views",
          time: "2 years ago",
          duration: "30:56",
          thumbnailUrl: "assets/images/video_thumb_1.png",
          creatorAvatarUrl: "assets/images/user_avatar.png",
          onMorePressed: () => showManagementBottomSheet(),
        );
      },
    );
  }
}
