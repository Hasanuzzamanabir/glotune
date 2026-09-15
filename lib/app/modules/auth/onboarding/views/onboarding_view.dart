import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/widgets/auth_widgets.dart';
import 'package:glotune/app/widgets/custom_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: controller.previousStep,
        ),
        title: const Text(
          'SIGN IN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Obx(() => _buildProgressBar()),

          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
                _buildStep6(),
                _buildStep7(),
                _buildStep8(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = controller.currentStep.value / controller.totalSteps;
    return Column(
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Text(
                "Step ${controller.currentStep.value} of ${controller.totalSteps}",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 4.h,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLayout({
    required String title,
    String? subtitle,
    required List<Widget> children,
    required VoidCallback onNext,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideX(begin: 0.1, end: 0),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
          ],
          SizedBox(height: 32.h),
          ...children,
          SizedBox(height: 40.h),
          Obx(
            () => controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : CustomButton(
                    text: 'Next',
                    onPressed: onNext,
                  ).animate().fadeIn(delay: 400.ms).scale(),
          ),
        ],
      ),
    );
  }

  // Step 1: Full Name
  Widget _buildStep1() {
    return _buildStepLayout(
      title: "What's your full name?",
      subtitle: "Let's get to know you better.",
      onNext: controller.nextStep,
      children: [
        AuthTextField(
          label: "Full name",
          hint: "Enter your full name",
          icon: Icons.person_outline,
          controller: controller.fullNameController,
        ),
      ],
    );
  }

  // Step 2: Username
  Widget _buildStep2() {
    return _buildStepLayout(
      title: "Let's know about you",
      subtitle: "Choose a name others will see on your profile",
      onNext: controller.nextStep,
      children: [
        AuthTextField(
          label: "Username",
          hint: "@username",
          icon: Icons.alternate_email,
          controller: controller.usernameController,
        ),
      ],
    );
  }

  // Step 3: Password
  Widget _buildStep3() {
    return _buildStepLayout(
      title: "Create a password",
      subtitle: "Use at least 8 characters with a mix of letters, numbers",
      onNext: controller.nextStep,
      children: [
        AuthTextField(
          label: "Password",
          hint: "New password",
          icon: Icons.lock_outline,
          isPassword: true,
          controller: controller.passwordController,
        ),
      ],
    );
  }

  // Step 4: Category
  Widget _buildStep4() {
    final categories = [
      "Content creators",
      "Talent managers",
      "Merchants",
      "Media Network",
    ];
    return _buildStepLayout(
      title: "Choose your category",
      subtitle: "Select the role that best represents you.",
      onNext: controller.nextStep,
      children: [
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: categories
              .map(
                (cat) => Obx(() {
                  bool isSelected = controller.selectedCategory.value == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) =>
                        controller.selectedCategory.value = cat,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                  );
                }),
              )
              .toList(),
        ),
      ],
    );
  }

  // Step 5: Partnership
  Widget _buildStep5() {
    final categories = [
      "Content creators",
      "Talent managers",
      "Merchants",
      "Media Network",
    ];
    return _buildStepLayout(
      title: "Partnership",
      subtitle:
          "Select one or more categories of users you're looking to connect with",
      onNext: controller.nextStep,
      children: [
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: categories
              .map(
                (cat) => Obx(() {
                  bool isSelected = controller.selectedPartnerships.contains(
                    cat,
                  );
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => controller.togglePartnership(cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                  );
                }),
              )
              .toList(),
        ),
      ],
    );
  }

  // Step 6: Location
  Widget _buildStep6() {
    return _buildStepLayout(
      title: "Select your country",
      subtitle:
          "This helps us show you content and matches relevant to your region",
      onNext: controller.nextStep,
      children: [
        _buildDropdown(
          label: "Country",
          hint: "Choose where you are from",
          selectedValue: controller.selectedCountry,
          itemsMap: controller.availableCountries,
        ),
        SizedBox(height: 20.h),
        _buildDropdown(
          label: "City",
          hint: "Choose where you are from",
          selectedValue: controller.selectedCity,
          itemsMap: controller.availableCities,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required Rxn<String> selectedValue,
    required RxMap<String, int> itemsMap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(
              () => DropdownButton<String>(
                isExpanded: true,
                value: selectedValue.value,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14.sp,
                  ),
                ),
                items: itemsMap.keys
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedValue.value = val;
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 7: Profile Picture
  Widget _buildStep7() {
    return _buildStepLayout(
      title: "Upload a profile picture",
      subtitle: "People connect better with a face. Make it yours",
      onNext: controller.nextStep,
      children: [
        Center(
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Stack(
              children: [
                Obx(() {
                  final imageFile = controller.profileImage.value;
                  return Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      image: imageFile != null
                          ? DecorationImage(
                              image: FileImage(imageFile),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageFile == null
                        ? Icon(Icons.person, size: 80.w, color: Colors.white)
                        : null,
                  );
                }),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20.w,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 8: Terms
  Widget _buildStep8() {
    return _buildStepLayout(
      title: "Terms and conditions",
      subtitle: "Please review and accept our terms to proceed.",
      onNext: controller.nextStep,
      children: [
        Text(
          "Before proceeding, please review and agree to our Terms and conditions and Privacy policy.",
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Obx(
              () => Checkbox(
                value: controller.isTermsAccepted.value,
                onChanged: (val) =>
                    controller.isTermsAccepted.value = val ?? false,
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: Text(
                "I understand and consent to participate",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
