import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../../controllers/create_controller.dart';

class EditPostView extends GetView<CreateController> {
  const EditPostView({super.key});

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
          'Edit post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image Preview
                  Obx(
                    () => Container(
                      height: 300.h,
                      margin: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: controller.selectedMediaPath.value.isNotEmpty
                              ? FileImage(
                                      File(controller.selectedMediaPath.value),
                                    )
                                    as ImageProvider
                              : const AssetImage(
                                  'assets/images/signin_option_bg.jpg',
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Title Input
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: TextField(
                      onChanged: (val) => controller.postTitle.value = val,
                      decoration: InputDecoration(
                        hintText: "Enter a title...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // Category Selection
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Obx(() {
                      if (controller.isCategoriesLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.categoriesList.isEmpty) {
                        return const Text("No categories found.");
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: controller.postCategory.value,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            items: controller.categoriesList.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                controller.postCategory.value = val;
                            },
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Row(
                          //       children: [
                          //         IconButton(
                          //           icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          //           onPressed: () {
                          //             if (controller.postCategory.value == null) return;
                          //             final textController = TextEditingController(
                          //               text: controller.categoriesList.firstWhere((c) => c.id == controller.postCategory.value).name
                          //             );
                          //             Get.dialog(
                          //               AlertDialog(
                          //                 title: const Text("Edit Category"),
                          //                 content: TextField(
                          //                   controller: textController,
                          //                   decoration: const InputDecoration(hintText: "Category name"),
                          //                 ),
                          //                 actions: [
                          //                   TextButton(
                          //                     onPressed: () => Get.back(),
                          //                     child: const Text("Cancel"),
                          //                   ),
                          //                   TextButton(
                          //                     onPressed: () {
                          //                       if (textController.text.isNotEmpty) {
                          //                         controller.updateCategory(controller.postCategory.value!, textController.text);
                          //                         Get.back();
                          //                       }
                          //                     },
                          //                     child: const Text("Save"),
                          //                   ),
                          //                 ],
                          //               )
                          //             );
                          //           },
                          //         ),
                          //         IconButton(
                          //           icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          //           onPressed: () {
                          //             if (controller.postCategory.value == null) return;
                          //             Get.dialog(
                          //               AlertDialog(
                          //                 title: const Text("Delete Category"),
                          //                 content: const Text("Are you sure you want to delete this category?"),
                          //                 actions: [
                          //                   TextButton(
                          //                     onPressed: () => Get.back(),
                          //                     child: const Text("Cancel"),
                          //                   ),
                          //                   TextButton(
                          //                     onPressed: () {
                          //                       controller.deleteCategory(controller.postCategory.value!);
                          //                       Get.back();
                          //                     },
                          //                     child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          //                   ),
                          //                 ],
                          //               )
                          //             );
                          //           },
                          //         ),
                          //       ],
                          //     ),
                          //   ],
                          // )
                        ],
                      );
                    }),
                  ),

                  // Caption Input
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: TextField(
                      onChanged: (val) => controller.postCaption.value = val,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        hintText: "Write a description...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Post Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
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
                          "Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
