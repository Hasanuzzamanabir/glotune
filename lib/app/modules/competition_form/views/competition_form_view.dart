import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/competition_form_controller.dart';

class CompetitionFormView extends GetView<CompetitionFormController> {
  const CompetitionFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'GloTune Competittion Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: Obx(() {
                if (controller.currentStep.value == 1) {
                  return _buildStep1();
                } else if (controller.currentStep.value == 2) {
                  return _buildStep2();
                } else if (controller.currentStep.value == 3) {
                  return _buildStep3();
                } else {
                  return _buildStep4();
                }
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.w),
        child: Obx(() {
          return CustomButton(
            text: controller.currentStep.value == 4 ? 'Submit' : 'Next',
            onPressed: () {
              if (controller.currentStep.value == 4) {
                controller.submitForm();
              } else {
                controller.nextStep();
              }
            },
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.previousStep(),
            child: Icon(Icons.arrow_back_ios, size: 16.w, color: Colors.black54),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Obx(() {
              return Stack(
                children: [
                  Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: controller.currentStep.value / 4.0,
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Content Creator's Details",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Tell us a little about yourself so we know who's stepping into the spotlight.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                      size: 32.w,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Upload profile picture",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildTextField("First name of applicant"),
          SizedBox(height: 12.h),
          _buildTextField("Surname of applicant"),
          SizedBox(height: 12.h),
          _buildTextField("Competition nickname"),
          SizedBox(height: 12.h),
          _buildTextField("Age"),
          SizedBox(height: 12.h),
          _buildDropdown("Sex"),
          SizedBox(height: 12.h),
          _buildDropdown("Country of residence"),
          SizedBox(height: 12.h),
          _buildDropdown("City of residence"),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "GloTune Family Details",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Help us understand your connection within the GloTune network",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildTextField("Your GloTune account"),
          SizedBox(height: 12.h),
          _buildDropdown("Content area for this competition"),
          SizedBox(height: 12.h),
          _buildTextField("Your GloTune group name"),
          SizedBox(height: 12.h),
          _buildDropdown("Your GloTune group size"),
          SizedBox(height: 12.h),
          _buildTextField("Full name of talent manager"),
          SizedBox(height: 12.h),
          _buildDropdown("Country of your talent manager"),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Affiliation & Sponsorship Details",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Let's get to know your partners and the companies supporting your creative journey.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildTextField("Name of affiliate company"),
          SizedBox(height: 12.h),
          _buildDropdown("Country of operation of company"),
          SizedBox(height: 12.h),
          _buildTextField("Address of affiliate company"),
          SizedBox(height: 12.h),
          _buildTextField("Email of the affiliate company"),
          SizedBox(height: 12.h),
          _buildDropdown("Business scope of your affiliate"),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Registration Fee",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Secure your spot by paying the one-time registration fee.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "\$1",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Registration fee",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment method",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: Colors.grey[200]),
                      SizedBox(height: 12.h),
                      _buildPaymentOption("Tips"),
                      SizedBox(height: 16.h),
                      _buildPaymentOption("Coins (100 coins = \$1)"),
                      SizedBox(height: 16.h),
                      _buildPaymentOption("Credit (20 credits = \$1)"),
                      SizedBox(height: 16.h),
                      _buildPaymentOption("Other (Bank, Paypal...)"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Note",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Approval is based on your violation history and the organizers' specific interests during the competition window. Once approved, you'll receive a candidate number and official badge for the competition day.",
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: const [],
          onChanged: (value) {},
        ),
      ),
    );
  }
}
