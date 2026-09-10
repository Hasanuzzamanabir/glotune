import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/media_network_profile_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MediaNetworkProfileView extends GetView<MediaNetworkProfileController> {
  const MediaNetworkProfileView({super.key});

  String _formatStatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final profile = profileController.activeProfile.value;
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, profile),
              _buildUserInfo(profile),
              _buildStatsDashboard(profile),
              _buildVerificationBanner(),
            SizedBox(height: 10.h),
            _buildMenuSection(),
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
          height: 200.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                "https://picsum.photos/800/400?random=40",
              ), // Adjust image based on design
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(
              0.2,
            ), // Darken slightly for readability
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Share.share('Check out this media network profile on Glotune!');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Share Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.SETTINGS),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -50.h,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFFA51B1B), // Dark Red Border
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.white,
              backgroundImage: profile.avatarUrl.startsWith('http')
                  ? CachedNetworkImageProvider(profile.avatarUrl) as ImageProvider
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
              Icon(Icons.verified, color: Colors.blue, size: 20.sp),
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
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(UserProfile profile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
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
          _buildStatItem(_formatStatCount(profile.subscribersCount), "Subscribers"),
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
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B00F8),
            Color(0xFFEE8775),
          ], // Purple to Orange gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: GestureDetector(
      onTap: () => Get.toNamed(Routes.MANAGER_VERIFICATION),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Complete Your Verification",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    "Verify",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16.sp),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment,
              color: const Color(0xFF7B2CBF),
              size: 28.sp,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          Icons.campaign,
          "Proposal center",
          "proposal center",
          onTap: () => Get.toNamed(Routes.CREATE_PROPOSAL),
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          Icons.receipt_long,
          "Media collaboration",
          "View media collaboration",
          onTap: () => Get.toNamed(Routes.MEDIA_COLLABORATION),
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          Icons.business_center,
          "Performance log",
          "Check all performance logs",
          onTap: () => Get.toNamed(Routes.PERFORMANCE_LOG),
        ),
      ],
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16.w,
      endIndent: 16.w,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFF8B1D1D).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF8B1D1D), size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.black, size: 20.sp),
      onTap: onTap ?? () {},
    );
  }
}
