import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import '../controllers/success_controller.dart';

class SuccessView extends GetView<SuccessController> {
  const SuccessView({super.key});
  @override
  Widget build(BuildContext context) {
    final flow = Get.arguments?['flow'] ?? 'register';
    final isRegister = flow == 'register';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          isRegister ? 'ACCOUNT CREATION' : 'FORGOT PASSWORD',
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),
              
              // Success Icon
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80.w,
                  ),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              
              SizedBox(height: 32.h),
              Text(
                'Success',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: 8.h),
              Text(
                isRegister 
                  ? 'Your account has been successfully created'
                  : 'Your password has been reset. Login to continue exploring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: 40.h),
              CustomButton(
                text: 'Login',
                onPressed: () => Get.offAllNamed(Routes.LOGIN),
              ).animate().fadeIn(delay: 600.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }
}
