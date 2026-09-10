import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/talent_manager_profile_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class TalentManagerProfileView extends GetView<TalentManagerProfileController> {
  const TalentManagerProfileView({super.key});

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
            _buildListTile(
              icon: Icons.campaign,
              title: "Manage Creators",
              subtitle: "View all past videos watched",
              onTap: () => Get.toNamed('/manage-creators'),
            ),
            // My Creators has been merged with Manage Creators
            _buildDivider(),
            _buildListTile(
              icon: Icons.receipt_long,
              title: "Sponsorship center",
              subtitle: "View all past videos watched",
              onTap: () => Get.toNamed(Routes.SPONSORSHIP_CENTER),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.receipt_long,
              title: "Deals management",
              subtitle: "View all past videos watched",
              onTap: () => Get.toNamed(Routes.DEALS_MANAGEMENT),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.business_center,
              title: "Scouting tools information",
              subtitle: "View all past videos watched",
              onTap: () => Get.toNamed(Routes.SCOUTING_TOOLS),
            ),
            _buildDivider(),
            _buildToggleTile(
              icon: Icons.receipt_long,
              title: "Open invite for creators",
              subtitle: "Allow creators send an invite",
            ),
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
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: CachedNetworkImageProvider('https://picsum.photos/800/400?random=111'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.3),
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
                  Share.share('Check out this talent manager profile on Glotune!');
                },
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, color: Colors.white, size: 20.sp),
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
                    Icon(Icons.settings_outlined, color: Colors.white, size: 20.sp),
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
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: Color(0xFF8B1D1D),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey[200],
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
              Text(profile.name, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 4.w),
              Icon(Icons.business_center, color: Colors.green, size: 20.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Text(profile.handle, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.country != null) ...[
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text("${profile.country}${profile.city != null ? ', ${profile.city}' : ''}", style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              ] else ...[
                Text("Global", style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(UserProfile profile) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
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
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30.h, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildVerificationBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A00FF), Color(0xFFA133FF)],
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
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    "Verify",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.fact_check, color: const Color(0xFF6A8EAE), size: 30.sp),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF8B1D1D), size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
      trailing: Icon(Icons.chevron_right, color: Colors.black, size: 20.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildToggleTile({required IconData icon, required String title, required String subtitle}) {
    return Obx(() => ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF8B1D1D), size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
      trailing: Switch(
        value: controller.openInviteForCreators.value,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xFF8B1D1D),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey[300],
        onChanged: controller.toggleOpenInvite,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    ));
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1), indent: 70.w);
  }
}
