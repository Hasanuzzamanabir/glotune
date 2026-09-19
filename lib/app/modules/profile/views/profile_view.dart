import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final profile = controller.activeProfile.value;
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, profile),
              _buildUserInfo(profile),
              _buildStatsDashboard(profile),
              _buildPrimaryActions(),
              _buildSectionHeader("Shorts"),
              _buildShortsCarousel(),
              _buildSectionHeader("Videos"),
              _buildVideosCarousel(),
              _buildSectionHeader("Fav List"),
              _buildFavoritesCarousel(),
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
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: InkWell(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
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
                    icon: Icon(
                      Icons.playlist_add_check,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50.h,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFF8B1D1D),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey[200],
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
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.workspace_premium, color: Colors.orange, size: 20.sp),
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
              const Icon(Icons.flag, color: Colors.black, size: 16),
              SizedBox(width: 4.w),
              Text(
                (profile.country != null && profile.city != null)
                    ? '${profile.country}, ${profile.city}'
                    : (profile.country ??
                          profile.city ??
                          'Location unavailable'),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatStatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return count.toString();
  }

  Widget _buildStatsDashboard(UserProfile profile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(vertical: 16.h),
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
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
          _buildActionButton(
            "View as public",
            onTap: () => Get.toNamed(Routes.PUBLIC_PROFILE),
          ),
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
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildVideosCarousel() {
    String formatCount(int count) {
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
      }
      if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
      }
      return count.toString();
    }

    if (controller.isVideosLoading.value) {
      return SizedBox(
        height: 180.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.ownVideosList.isEmpty) {
      return SizedBox(
        height: 180.h,
        child: Center(
          child: Text(
            "No videos uploaded yet.",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.ownVideosList.length,
        itemBuilder: (context, index) {
          final video = controller.ownVideosList[index];
          return GestureDetector(
            onTap: () => Get.toNamed(Routes.VIDEO_PLAYER, arguments: video),
            child: Container(
              width: 220.w,
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      color: Colors.grey[800],
                      height: 130.h,
                      width: 220.w,
                      child: video.thumbnail != null
                          ? Image.network(
                              video.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.video_library,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.video_library,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${formatCount(video.viewsCount)} views • ${video.createdAtAgoTime ?? ''}",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortsCarousel() {
    String formatCount(int count) {
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
      }
      if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
      }
      return count.toString();
    }

    if (controller.isShortsLoading.value) {
      return SizedBox(
        height: 220.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.ownShortsList.isEmpty) {
      return SizedBox(
        height: 220.h,
        child: Center(
          child: Text(
            "No shorts uploaded yet.",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.ownShortsList.length,
        itemBuilder: (context, index) {
          final short = controller.ownShortsList[index];
          return GestureDetector(
            onTap: () => Get.toNamed(
              Routes.SHORTS_PLAYER,
              arguments: {
                'shortsList': controller.ownShortsList,
                'initialIndex': index,
              },
            ),
            child: Container(
              width: 120.w,
              margin: EdgeInsets.only(right: 12.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.grey[800],
                      child: short.thumbnail != null
                          ? Image.network(
                              short.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.video_library,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.video_library,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            formatCount(short.viewsCount),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesCarousel() {
    if (controller.isFavoritesLoading.value) {
      return SizedBox(
        height: 180.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.favoritesList.isEmpty) {
      return SizedBox(
        height: 180.h,
        child: Center(
          child: Text(
            "No favorites yet.",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.favoritesList.length,
        itemBuilder: (context, index) {
          final fav = controller.favoritesList[index];
          // Since the API only provides contentId, we use dummy details mapped to that ID for now.
          return Container(
            width: 220.w,
            margin: EdgeInsets.only(right: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    color: Colors.grey[800],
                    height: 130.h,
                    width: 220.w,
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Content #${fav.contentId}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Favorited by User #${fav.user}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
