import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/viewer_profile_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class ViewerProfileView extends GetView<ViewerProfileController> {
  const ViewerProfileView({super.key});

  String _formatStatCount(int count) {
    if (count >= 1000000)
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    if (count >= 1000)
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final profile = profileController.activeProfile.value;
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, profile),
              _buildUserInfo(profile),
              _buildStatsDashboard(profile),
              _buildPrimaryActions(),
              _buildSectionHeader("Watchlist"),
              _buildHorizontalCarousel(isWatchlist: true),
              _buildSectionHeader("Continue from playing"),
              _buildHorizontalCarousel(isWatchlist: false),
              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile profile) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Grey Banner Area
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_note,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Avatar with Red Border
        Positioned(
          bottom: -50.h,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFF8B1D1D), // Maroon/Red border
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundImage: profile.avatarUrl.startsWith('http')
                  ? CachedNetworkImageProvider(profile.avatarUrl)
                        as ImageProvider
                  : AssetImage(profile.avatarUrl) as ImageProvider,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserProfile profile) {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.military_tech, color: Colors.orange, size: 24.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            profile.handle,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.country != null || profile.city != null) ...[
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  (profile.country != null && profile.city != null)
                      ? '${profile.country}, ${profile.city}'
                      : (profile.country ?? profile.city!),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ] else ...[
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'Global',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(UserProfile profile) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(_formatStatCount(profile.followersCount), "Followers"),
          _buildStatDivider(),
          _buildStatItem(_formatStatCount(profile.followingCount), "Following"),
          _buildStatDivider(),
          _buildStatItem(
            _formatStatCount(profile.subscribersCount),
            "Subscribers",
          ),
          _buildStatDivider(),
          _buildStatItem(_formatStatCount(profile.videosCount), "Videos"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30.h,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildPrimaryActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildActionButton(
            "Engagement history",
            onTap: () => Get.toNamed(Routes.ENGAGEMENT_HISTORY),
          ),
          SizedBox(width: 12.w),
          _buildActionButton("Switch account", onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFF8B1D1D), width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF8B1D1D),
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCarousel({required bool isWatchlist}) {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 200.w,
            margin: EdgeInsets.only(right: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    isWatchlist
                        ? 'assets/images/video_thumb_1.png'
                        : 'assets/images/video_thumb_2.png',
                    height: 110.h,
                    width: 200.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isWatchlist ? "Rich Mindset" : "Dad, Rich Dad",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Golden Myron",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
