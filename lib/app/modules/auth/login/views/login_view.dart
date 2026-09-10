import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/widgets/auth_widgets.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              SizedBox(height: 8.h),
              Text(
                'Sign in to continue your personalized and entailed journey',
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
              SizedBox(height: 20.h),

              AuthTextField(
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: controller.passwordController,
              ).animate().fadeIn(delay: 500.ms),

              SizedBox(height: 32.h),

              Obx(() => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : CustomButton(
                      text: 'Sign in',
                      onPressed: controller.login,
                    ).animate().fadeIn(delay: 600.ms).scale()),

              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),

              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.REGISTER),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
