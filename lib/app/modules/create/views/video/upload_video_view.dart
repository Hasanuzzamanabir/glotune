import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/create_controller.dart';

class UploadVideoView extends GetView<CreateController> {
  const UploadVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => controller.navigateTo("Camera"),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Upload Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Thumbnail Preview Placeholder
            Container(
              height: 200.h,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Obx(
                    () => controller.selectedMediaPath.value.isNotEmpty
                        ? ClipRect(
                            child: _VideoPreviewWidget(
                              path: controller.selectedMediaPath.value,
                            ),
                          )
                        : Container(),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Custom Thumbnail Selection
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Obx(
                    () => Container(
                      height: 60.h,
                      width: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        image: controller.selectedThumbnailPath.value.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(
                                  File(controller.selectedThumbnailPath.value),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: controller.selectedThumbnailPath.value.isEmpty
                          ? Icon(Icons.image, color: Colors.grey[500])
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Custom Thumbnail",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Upload a picture that shows what's in your video",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: controller.pickThumbnail,
                    child: const Text("Upload"),
                  ),
                ],
              ),
            ),

            // Upload Form
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextField(
                    onChanged: (val) => controller.videoTitle.value = val,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: "Title",
                      hintText: "Enter a title for your video",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Description Input
                  TextField(
                    onChanged: (val) => controller.videoDescription.value = val,
                    maxLines: 4,
                    maxLength: 5000,
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Tell viewers about your video",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Privacy Settings
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.public),
                    title: const Text("Visibility"),
                    subtitle: Obx(() => Text(controller.streamPrivacy.value)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () {
                      Get.bottomSheet(
                        Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("Public"),
                                leading: const Icon(Icons.public),
                                onTap: () {
                                  controller.streamPrivacy.value = "Public";
                                  Get.back();
                                },
                              ),
                              ListTile(
                                title: const Text("Unlisted"),
                                leading: const Icon(Icons.link),
                                onTap: () {
                                  controller.streamPrivacy.value = "Unlisted";
                                  Get.back();
                                },
                              ),
                              ListTile(
                                title: const Text("Private"),
                                leading: const Icon(Icons.lock),
                                onTap: () {
                                  controller.streamPrivacy.value = "Private";
                                  Get.back();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32.h),
                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isPosting.value
                            ? null
                            : () => controller.submitPost(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: controller.isPosting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Upload",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPreviewWidget extends StatefulWidget {
  final String path;
  const _VideoPreviewWidget({required this.path});

  @override
  State<_VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<_VideoPreviewWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
