import 'dart:io';
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
          // Dark Overlay for contrast
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  // App Logo (BR_001 Alignment & Figma Match)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 90.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  SizedBox(height: 16.h),
                  Text(
                    'GloTune',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  SizedBox(height: 8.h),
                  Text(
                    'Connect, stream, and share music with the world',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const Spacer(),

                  // Sign in with Google (BR_002)
                  CustomButton(
                    text: 'Sign in with Google',
                    onPressed: controller.loginWithGoogle,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconPath: 'assets/icons/google.svg',
                  ).animate().slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
                  SizedBox(height: 14.h),

                  // Sign in with Apple - Hidden on Android (BR_003)
                  if (!Platform.isAndroid) ...[
                    CustomButton(
                      text: 'Sign in with Apple',
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      iconPath: 'assets/icons/apple.svg',
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 500.ms,
                      delay: 100.ms,
                      curve: Curves.easeOut,
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // Sign in with password
                  CustomButton(
                    text: 'Sign in with password',
                    onPressed: () => Get.toNamed(Routes.LOGIN),
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ).animate().slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 500.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

