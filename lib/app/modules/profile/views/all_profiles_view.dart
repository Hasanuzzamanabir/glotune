import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/profile_controller.dart';

class AllProfilesView extends GetView<ProfileController> {
  const AllProfilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "All Profiles",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.allProfiles.length,
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final profile = controller.allProfiles[index];
            final isActive = controller.activeProfile.value.id == profile.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage: profile.avatarUrl.startsWith('http')
                    ? CachedNetworkImageProvider(profile.avatarUrl)
                          as ImageProvider
                    : AssetImage(profile.avatarUrl) as ImageProvider,
                radius: 24.r,
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      profile.type,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(profile.handle),
              trailing: isActive
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Get.toNamed(profile.route);
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic to add a new profile
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
