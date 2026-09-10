import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import '../controllers/login_options_controller.dart';

class LoginOptionsView extends GetView<LoginOptionsController> {
  const LoginOptionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/signin_option_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay for better contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Sign in with Google',
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  iconPath: 'assets/icons/google.svg',
                ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: 'Sign in with Apple',
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  iconPath: 'assets/icons/apple.svg',
                ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 600.ms,
                  delay: 100.ms,
                  curve: Curves.easeOut,
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: 'Sign in with password',
                  onPressed: () => Get.toNamed(Routes.LOGIN),
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.easeOut,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
