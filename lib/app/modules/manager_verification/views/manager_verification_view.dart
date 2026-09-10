import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/manager_verification_controller.dart';
import 'widgets/verification_form_widget.dart';

class ManagerVerificationView extends GetView<ManagerVerificationController> {
  const ManagerVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Manager verification",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(() {
          return VerificationFormWidget(
            title: "Upload any of these ID to verify",
            buttonText: "Submit verification",
            fileName: controller.uploadedFileName.value,
            onPickFile: controller.pickFile,
            onSubmit: controller.submitVerification,
          );
        }),
      ),
    );
  }
}
