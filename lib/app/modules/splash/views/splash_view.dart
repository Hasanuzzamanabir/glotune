import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    // Initializing the controller if not done by binding
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset('assets/images/logo.jpg', width: 250.w)
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
