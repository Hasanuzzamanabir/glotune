import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/groups_controller.dart';

class GroupsView extends GetView<GroupsController> {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Groups',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.groups.isEmpty) {
          return Center(
            child: Text(
              "No groups found.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            final name = group['name'] as String? ?? 'Unnamed Group';
            final lastMsg = group['last_message'] as String? ?? 'No messages yet';
            final timeRaw = group['last_message_time'] ?? group['created_at'] ?? '';
            final timeStr = timeRaw.toString().length >= 10 ? timeRaw.toString().substring(0, 10) : '';
            final memberCount = group['member_count']?.toString() ?? '0';

            return ListTile(
              onTap: () {
                Get.toNamed(Routes.GROUP_DETAILS, arguments: group);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              leading: CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.group, color: AppColors.textSecondary),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    lastMsg,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$memberCount members',
                    style: TextStyle(fontSize: 10.sp, color: AppColors.primary),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(Routes.CREATE_GROUP);
          if (result == true) {
            controller.fetchGroups();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }
}
