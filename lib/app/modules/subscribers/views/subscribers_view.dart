import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/subscribers_controller.dart';

class SubscribersView extends GetView<SubscribersController> {
  const SubscribersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Subscribers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value!,
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          );
        }

        if (controller.subscribers.isEmpty) {
          return Center(
            child: Text(
              'No subscribers yet',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          itemCount: controller.subscribers.length,
          itemBuilder: (context, index) {
            final subscriber = controller.subscribers[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h, left: 16.w, right: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                leading: CircleAvatar(
                  radius: 25.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      subscriber.profilePicture != null &&
                          subscriber.profilePicture!.isNotEmpty
                      ? CachedNetworkImageProvider(subscriber.profilePicture!)
                      : const AssetImage('assets/images/user_avatar.png')
                            as ImageProvider,
                ),
                title: Text(
                  subscriber.fullName.isNotEmpty
                      ? subscriber.fullName
                      : subscriber.username,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Subscribed ${subscriber.subscribeTime}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onPressed: () {
                    _showSubscriberOptions(context, index);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showSubscriberOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle_outline, color: Colors.red),
                  title: Text(
                    'Remove Subscriber',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.removeSubscriber(index);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.close, color: AppColors.textPrimary),
                  title: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
