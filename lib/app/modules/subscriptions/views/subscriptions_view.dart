import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized if used inside another view
    if (!Get.isRegistered<SubscriptionsController>()) {
      Get.put(SubscriptionsController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return CustomScrollView(
          slivers: [
            // Subscriptions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subscriptions',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.snackbar(
                        "Info",
                        "See all subscriptions feature coming soon",
                      ),
                      child: Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Channel List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100.h,
                child: controller.subscriptions.isEmpty
                    ? Center(
                        child: Text(
                          "No subscriptions yet.",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: controller.subscriptions.length,
                        itemBuilder: (context, index) {
                          final sub = controller.subscriptions[index];
                          final avatarUrl = sub['profile_picture'] as String?;
                          final name =
                              sub['full_name'] ?? sub['username'] ?? 'User';

                          return GestureDetector(
                            onTap: () => Get.toNamed(
                              Routes.CREATOR_CHANNEL,
                              arguments: sub,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(right: 16.w),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage:
                                        (avatarUrl != null &&
                                            avatarUrl.isNotEmpty)
                                        ? CachedNetworkImageProvider(avatarUrl)
                                              as ImageProvider
                                        : const AssetImage(
                                            'assets/images/user_avatar.png',
                                          ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    width: 60.r,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Subscription List with Details
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final sub = controller.subscriptions[index];
                return _buildSubscriptionItem(sub);
              }, childCount: controller.subscriptions.length),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSubscriptionItem(Map<String, dynamic> sub) {
    final avatarUrl = sub['profile_picture'] as String?;
    final name = sub['full_name'] ?? sub['username'] ?? 'User';
    final subCount = sub['subscriber_count'] ?? '0';

    return ListTile(
      onTap: () => Get.toNamed(Routes.CREATOR_CHANNEL, arguments: sub),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 24.r,
        backgroundColor: Colors.grey[200],
        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
            : const AssetImage('assets/images/user_avatar.png'),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$subCount Subscribers',
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
      trailing: GestureDetector(
        onTap: () => _showAlertPreferencesBottomSheet(name),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertPreferencesBottomSheet(String channelName) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                "Alert settings for $channelName",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            _buildManagementItem(Icons.notifications_active, "All"),
            _buildManagementItem(Icons.notifications_none, "Personalized"),
            _buildManagementItem(Icons.notifications_off_outlined, "None"),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// Global Management Bottom Sheet
void showManagementBottomSheet() {
  Get.bottomSheet(
    Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          _buildManagementItem(
            Icons.watch_later_outlined,
            "Save to watch later",
          ),
          _buildManagementItem(Icons.playlist_add, "Save playlist"),
          _buildManagementItem(Icons.person_remove_outlined, "Unsubscribe"),
          _buildManagementItem(Icons.tv, "Link TV"),
          _buildManagementItem(Icons.share_outlined, "Share"),
          _buildManagementItem(
            Icons.info_outline,
            "Report",
            isDestructive: true,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildManagementItem(
  IconData icon,
  String label, {
  bool isDestructive = false,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isDestructive ? Colors.red : AppColors.primary,
      size: 24.sp,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: isDestructive ? Colors.red : AppColors.textPrimary,
      ),
    ),
    onTap: () => Get.back(),
  );
}
