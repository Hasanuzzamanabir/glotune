import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: TextStyle(fontSize: 20.sp, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('FORGOT PASSWORD', style: TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
                  Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  SizedBox(height: 8.h),
                  Text(
                    'Input the code sent to your email address',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  SizedBox(height: 32.h),
                  
                  Pinput(
                    length: 6,
                    onChanged: (value) => controller.otp.value = value,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyDecorationWith(
                      border: Border.all(color: AppColors.primary),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  SizedBox(height: 16.h),
                  Obx(() => Text(
                    controller.timerText,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  )),
                  
                  SizedBox(height: 32.h),
                  
                  Obx(() => controller.isLoading.value
                      ? SizedBox(
                          height: 56.h,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      : CustomButton(
                          text: 'Verify',
                          onPressed: controller.verifyOtp,
                        ).animate().fadeIn(delay: 600.ms).scale()),
                  
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      Obx(() => GestureDetector(
                        onTap: controller.countdown.value == 0 
                            ? () => controller.startTimer() 
                            : null,
                        child: Text(
                          "Resend",
                          style: TextStyle(
                            color: controller.countdown.value == 0 
                                ? AppColors.primary 
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
