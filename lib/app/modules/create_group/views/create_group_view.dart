import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/create_group_controller.dart';

class CreateGroupView extends GetView<CreateGroupController> {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Create Group',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            if (controller.isCreating.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () => controller.createGroup(),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    hintText: 'Group Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Members',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isFriendsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.friends.isEmpty) {
                return const Center(child: Text('No friends found.'));
              }
              return ListView.builder(
                itemCount: controller.friends.length,
                itemBuilder: (context, index) {
                  final friend = controller.friends[index];
                  final user = friend['subscriber_details'] ?? friend['publisher_details'];
                  if (user == null) return const SizedBox.shrink();

                  final id = user['id'] as int;
                  final name = user['full_name'] ?? user['username'] ?? 'User';
                  final avatarUrl = user['profile_picture'] as String?;

                  final isSelected = controller.selectedFriends.contains(id);

                  return ListTile(
                    onTap: () => controller.toggleFriendSelection(id),
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
                          : const AssetImage('assets/images/user_avatar.png'),
                    ),
                    title: Text(name),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
