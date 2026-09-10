import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/widgets/auth_widgets.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import 'package:country_picker/country_picker.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Text(
                'Create account',
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

              Obx(() => AuthTextField(
                label: 'Email or Phone number',
                hint: 'Enter your email or phone number',
                icon: Icons.person_outline,
                controller: controller.emailController,
                prefixWidget: controller.isPhoneNumber.value
                    ? GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              controller.updateCountry(country);
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          color: Colors.transparent, // to make the whole row clickable
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.selectedCountryFlag.value,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '+${controller.selectedCountryCode.value}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              SizedBox(width: 8.w),
                              Container(
                                width: 1.w,
                                height: 24.h,
                                color: AppColors.border,
                              ),
                              SizedBox(width: 8.w),
                            ],
                          ),
                        ),
                      )
                    : null,
              )).animate().fadeIn(delay: 400.ms),

              SizedBox(height: 32.h),

              Obx(() => controller.isLoading.value
                  ? SizedBox(
                      height: 56.h,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  : CustomButton(
                      text: 'Sign up',
                      onPressed: controller.register,
                    ).animate().fadeIn(delay: 600.ms).scale()),

              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Sign in",
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
