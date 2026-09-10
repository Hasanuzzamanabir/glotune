import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/widgets/auth_widgets.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'FORGOT PASSWORD',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Text(
                'Reset password',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              SizedBox(height: 8.h),
              Text(
                'Forgot password? We\'ve got you covered',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: 32.h),

              AuthTextField(
                label: 'Email or Phone number',
                hint: 'Enter your email or phone number',
                icon: Icons.person_outline,
                controller: controller.inputController,
              ).animate().fadeIn(delay: 400.ms),

              SizedBox(height: 32.h),

              Obx(() => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : CustomButton(
                      text: 'Send code',
                      onPressed: controller.requestOtp,
                    ).animate().fadeIn(delay: 600.ms).scale()),
            ],
          ),
        ),
      ),
    );
  }
}
