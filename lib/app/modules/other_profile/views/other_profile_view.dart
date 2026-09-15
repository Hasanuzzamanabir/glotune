import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/core/utils/report_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/other_profile_controller.dart';

class OtherProfileView extends GetView<OtherProfileController> {
  const OtherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isProfileLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final profile = controller.profileData.value;
        if (profile == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value ?? "User not found",
                    style: const TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Go Back",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, profile),
              _buildUserInfo(profile),
              _buildStatsDashboard(profile),
              _buildPrimaryActions(profile),
              _buildSectionHeader("Shorts"),
              _buildShortsCarousel(),
              _buildSectionHeader("Videos"),
              _buildVideosCarousel(),
              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, profile) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Grey Banner Area
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            image:
                profile.coverPhotoUrl != null &&
                    profile.coverPhotoUrl!.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(profile.coverPhotoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
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
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Public Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (controller.profileData.value != null) {
                            ReportUtils.showReportUserDialog(
                              controller.profileData.value!.id,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: controller.shareProfile,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
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
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  profile.profilePictureUrl != null &&
                      profile.profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(profile.profilePictureUrl!)
                        as ImageProvider
                  : const AssetImage('assets/images/user_avatar.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(profile) {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.fullName?.isNotEmpty == true
                    ? profile.fullName!
                    : "Unknown User",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (profile.userType == "Premium" ||
                  profile.userType == "Admin") ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.workspace_premium,
                  color: Colors.orange,
                  size: 20.sp,
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            profile.email ?? "",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          if (profile.country != null || profile.city != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag, color: Colors.black, size: 16),
                SizedBox(width: 4.w),
                Text(
                  [
                    profile.country,
                    profile.city,
                  ].where((e) => e != null && e.isNotEmpty).join(", "),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String formatCount(int count) {
    if (count >= 1000000)
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    if (count >= 1000)
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    return count.toString();
  }

  Widget _buildStatsDashboard(profile) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() {
        final currentProfile = controller.profileData.value ?? profile;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              formatCount(currentProfile.followerCount),
              "Followers",
            ),
            _buildStatDivider(),
            _buildStatItem(
              formatCount(currentProfile.followingCount),
              "Following",
            ),
            _buildStatDivider(),
            _buildStatItem(
              formatCount(currentProfile.subscriberCount),
              "Subscribers",
            ),
            _buildStatDivider(),
            _buildStatItem(formatCount(currentProfile.yourCoins), "Coins"),
          ],
        );
      }),
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

  Widget _buildPrimaryActions(profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Obx(
              () => _buildFilledButton(
                controller.isFollowing.value ? "Following" : "Follow",
                onTap: controller.toggleFollow,
                isLoading: controller.isFollowLoading.value,
                isFollowing: controller.isFollowing.value,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Obx(
              () => _buildFilledButton(
                controller.isSubscribed.value ? "Subscribed" : "Subscribe",
                onTap: controller.toggleSubscribe,
                isLoading: controller.isSubscribeLoading.value,
                isFollowing: controller
                    .isSubscribed
                    .value, // Using same style as follow button
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _showOptionsBottomSheet,
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

  Widget _buildFilledButton(
    String label, {
    VoidCallback? onTap,
    bool isLoading = false,
    bool isFollowing = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isFollowing
              ? Colors.grey[400]
              : const Color(0xFF8B1D1D), // Primary Theme color
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 16.sp,
                  width: 16.sp,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
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
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildVideosCarousel() {
    return Obx(() {
      if (controller.isContentLoading.value) {
        return SizedBox(
          height: 180.h,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (controller.userVideosList.isEmpty) {
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
          itemCount: controller.userVideosList.length,
          itemBuilder: (context, index) {
            final video = controller.userVideosList[index];
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
                        color: Colors.grey[300],
                        height: 130.h,
                        width: 220.w,
                        child:
                            video.thumbnail != null &&
                                video.thumbnail!.isNotEmpty
                            ? Image(
                                image: CachedNetworkImageProvider(
                                  video.thumbnail!,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(
                                    Icons.video_library,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                ),
                              )
                            : (video.video != null
                                  ? VideoThumbnailWidget(videoUrl: video.video!)
                                  : const Center(
                                      child: Icon(
                                        Icons.video_library,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    )),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      video.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
    });
  }

  Widget _buildShortsCarousel() {
    return Obx(() {
      if (controller.isContentLoading.value) {
        return SizedBox(
          height: 220.h,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (controller.userShortsList.isEmpty) {
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
          itemCount: controller.userShortsList.length,
          itemBuilder: (context, index) {
            final short = controller.userShortsList[index];
            return GestureDetector(
              onTap: () => Get.toNamed(
                Routes.SHORTS_PLAYER,
                arguments: controller.userShortsList.toList(),
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
                        color: Colors.grey[300],
                        child:
                            short.thumbnail != null &&
                                short.thumbnail!.isNotEmpty
                            ? Image(
                                image: CachedNetworkImageProvider(
                                  short.thumbnail!,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(
                                    Icons.video_library,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                ),
                              )
                            : (short.video != null
                                  ? VideoThumbnailWidget(videoUrl: short.video!)
                                  : const Center(
                                      child: Icon(
                                        Icons.video_library,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    )),
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
    });
  }

  void _showOptionsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              icon: Icons.person_add_alt_1_outlined,
              label: "Send Friend Request",
              onTap: () {
                Get.back();
                Get.snackbar("Friend Request", "Friend request sent!");
              },
            ),
            _buildOptionItem(
              icon: Icons.message_outlined,
              label: "Message",
              onTap: () {
                Get.back();
                // Navigate to chat / message screen
              },
            ),
            _buildOptionItem(
              icon: Icons.report_problem_outlined,
              label: "Report User",
              onTap: () {
                Get.back();
                Get.snackbar("Report", "User reported for review.");
              },
            ),
            _buildOptionItem(
              icon: Icons.block,
              label: "Block User",
              color: Colors.red,
              onTap: () {
                Get.back(); // close this sheet
                _showBlockConfirmationDialog();
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Block User"),
        content: const Text(
          "Are you sure you want to block this user? You will no longer see their content.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              controller.blockUser();
            },
            child: const Text(
              "Block",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontSize: 16.sp),
      ),
      onTap: onTap,
    );
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
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
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
