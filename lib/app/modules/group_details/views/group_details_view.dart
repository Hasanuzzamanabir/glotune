import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/group_details_controller.dart';

class GroupDetailsView extends GetView<GroupDetailsController> {
  const GroupDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Obx(() => Text(
          controller.groupDetails['name'] ?? controller.groupInfo['name'] ?? 'Group Details',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        )),
        leading: const BackButton(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'leave') {
                controller.leaveGroup(1, "member");
              } else if (value == 'delete') {
                Get.defaultDialog(
                  title: "Delete Group",
                  middleText: "Are you sure you want to delete this group permanently?",
                  textConfirm: "Delete",
                  textCancel: "Cancel",
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    Get.back();
                    controller.deleteGroup();
                  },
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'leave', child: Text('Leave Group')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Group', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.groupDetails.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final details = controller.groupDetails.isNotEmpty ? controller.groupDetails : controller.groupInfo;
        final description = details['description'] as String? ?? 'No description';
        final members = details['group_members'] as List? ?? [];

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  SizedBox(height: 4.h),
                  Text(description, style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Members (${members.length})", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      // In a real app, this would open a friend selector
                      // For now, we mock adding a random user id 2
                      controller.addMember(2, "member");
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text("Add"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final memberId = member['id'] as int;
                  final userId = member['user'] as int;
                  final role = member['role'] as String? ?? 'member';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    title: Text('User $userId', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(role.toUpperCase(), style: TextStyle(color: role == 'admin' ? AppColors.primary : AppColors.textSecondary)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'promote') {
                          controller.promoteMember(memberId, userId);
                        } else if (value == 'demote') {
                          controller.demoteMember(memberId, userId);
                        } else if (value == 'remove') {
                          controller.removeMember(memberId);
                        }
                      },
                      itemBuilder: (context) => [
                        if (role != 'admin')
                          const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                        if (role == 'admin')
                          const PopupMenuItem(value: 'demote', child: Text('Demote to Member')),
                        const PopupMenuItem(value: 'remove', child: Text('Remove from Group', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
