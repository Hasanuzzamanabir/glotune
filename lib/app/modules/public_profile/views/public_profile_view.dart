import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/public_profile_controller.dart';
import 'package:glotune/app/routes/app_pages.dart';

class PublicProfileView extends GetView<PublicProfileController> {
  const PublicProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PublicProfileController>()) {
      Get.put(PublicProfileController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildUserInfo(),
            _buildStatsDashboard(),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Grey Banner Area
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Public Profile",
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
                    icon: const Icon(Icons.share, color: Colors.white, size: 24),
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
              backgroundImage: const AssetImage('assets/images/user_avatar.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Cameron Williamson",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.workspace_premium, color: Colors.orange, size: 20.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "@camwils34",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flag, color: Colors.black, size: 16),
              SizedBox(width: 4.w),
              Text(
                "Germany, Frankfurt",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard() {
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
          _buildStatItem("12.3M", "Followers"),
          _buildStatDivider(),
          _buildStatItem("10k", "Following"),
          _buildStatDivider(),
          _buildStatItem("10k", "Subscribers"),
          _buildStatDivider(),
          _buildStatItem("10k", "Videos"),
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
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30.h,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildPrimaryActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildFilledButton("Follow", onTap: () {}),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: _buildActionButton("Message", onTap: () {}),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: const Icon(Icons.more_vert, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF8B1D1D), // Primary Theme color
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildVideosCarousel() {
    String formatCount(int count) {
      if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
      if (count >= 1000) return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
      return count.toString();
    }

    return Obx(() {
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
                            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.video_library, color: Colors.white54, size: 40)),
                          )
                        : (video.video != null 
                            ? VideoThumbnailWidget(videoUrl: video.video!) 
                            : const Center(child: Icon(Icons.video_library, color: Colors.white54, size: 40))),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(video.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("${formatCount(video.viewsCount)} views • ${video.createdAtAgoTime ?? ''}", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
            ));
          },
        ),
      );
    });
  }

  Widget _buildShortsCarousel() {
    String formatCount(int count) {
      if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
      if (count >= 1000) return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
      return count.toString();
    }

    return Obx(() {
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
              onTap: () => Get.toNamed(Routes.SHORTS_PLAYER, arguments: {
                'shortsList': controller.ownShortsList,
                'initialIndex': index,
              }),
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
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.video_library, color: Colors.white54, size: 40)),
                            )
                          : (short.video != null 
                              ? VideoThumbnailWidget(videoUrl: short.video!) 
                              : const Center(child: Icon(Icons.video_library, color: Colors.white54, size: 40))),
                    ),
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 16),
                          SizedBox(width: 2.w),
                          Text(
                            formatCount(short.viewsCount),
                            style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
      );
    });
  }

  Widget _buildFavoritesCarousel() {
    return Obx(() {
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
                      child: const Center(child: Icon(Icons.favorite, color: Colors.white54, size: 40)),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text("Content #${fav.contentId}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("Favorited by User #${fav.user}", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  const VideoThumbnailWidget({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    // Force HTTPS for thumbnail generation to avoid cleartext HTTP errors
    final secureUrl = widget.videoUrl.replaceFirst('http://', 'https://');
    _thumbnailFuture = VideoThumbnail.thumbnailData(
      video: secureUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 220,
      quality: 25,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.video_library, color: Colors.white54, size: 40),
            ),
          );
        } else {
          return const Center(
            child: Icon(Icons.video_library, color: Colors.white54, size: 40),
          );
        }
      },
    );
  }
}
