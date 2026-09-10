import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'mark_read') {
                controller.markAllAsRead();
              } else if (value == 'delete_all') {
                Get.defaultDialog(
                  title: "Delete All Notifications",
                  middleText: "Are you sure you want to delete all notifications? This action cannot be undone.",
                  textConfirm: "Delete",
                  textCancel: "Cancel",
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    Get.back(); // close dialog
                    controller.deleteAllNotifications();
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'mark_read',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Text('Delete all notifications', style: TextStyle(color: Colors.red)),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                _buildFilterChip("All", 0),
                SizedBox(width: 12.w),
                _buildFilterChip("Mentions", 1),
              ],
            ),
          ),
          
          // Notifications List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (controller.notifications.isEmpty) {
                return Center(
                  child: Text(
                    "No notifications found.",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return Obx(() {
      bool isSelected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.selectedIndex.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNotificationItem(int index) {
    final notification = controller.notifications[index];
    final id = notification['id'] as int? ?? 0;
    final sender = notification['sender'] as Map<String, dynamic>?;
    final avatarUrl = sender?['profile_picture'] as String?;
    final title = notification['title'] as String? ?? 'Notification';
    final message = notification['message'] as String? ?? '';
    final isRead = notification['is_read'] as bool? ?? true;
    
    // Convert created_at string to a readable format if needed (simplified here)
    final createdAt = notification['created_at'] as String? ?? '';
    final timeStr = createdAt.isNotEmpty && createdAt.length >= 10 ? createdAt.substring(0, 10) : '';

    return GestureDetector(
      onTap: () => controller.showNotificationDetails(id),
      child: Container(
        color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              leading: CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
                    : const AssetImage('assets/images/user_avatar.png'),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                      if (!isRead) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'view') {
                    controller.showNotificationDetails(id);
                  } else if (value == 'mark_read') {
                    controller.markNotificationAsRead(id);
                  } else if (value == 'delete') {
                    Get.defaultDialog(
                      title: "Delete Notification",
                      middleText: "Are you sure you want to delete this notification?",
                      textConfirm: "Delete",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                      onConfirm: () {
                        Get.back(); // close dialog
                        controller.deleteNotification(id);
                      },
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    if (!isRead)
                      const PopupMenuItem<String>(
                        value: 'mark_read',
                        child: Text('Mark as read'),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ];
                },
              ),
            ),
            Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ],
        ).animate().fadeIn(delay: (index * 50).ms),
      ),
    );
  }
}
