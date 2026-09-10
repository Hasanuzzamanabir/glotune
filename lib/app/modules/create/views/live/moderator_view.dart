import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../../controllers/create_controller.dart';

class ModeratorView extends GetView<CreateController> {
  const ModeratorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => controller.navigateTo("LiveStream"),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Moderator',
          style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add / remove moderators",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.moderators.length,
                itemBuilder: (context, index) {
                  final mod = controller.moderators[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: const AssetImage('assets/images/user_avatar.png'),
                    ),
                    title: Text(mod['name']!, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    subtitle: Text(mod['handle']!, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: index == 2 ? Colors.white : AppColors.primary,
                        foregroundColor: index == 2 ? Colors.red : Colors.white,
                        side: index == 2 ? const BorderSide(color: Colors.red) : null,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                      child: Text(index == 2 ? "Remove" : "Add"),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
