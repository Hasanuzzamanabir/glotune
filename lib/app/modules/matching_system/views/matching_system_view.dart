import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/matching_system_controller.dart';

class MatchingSystemView extends GetView<MatchingSystemController> {
  const MatchingSystemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => controller.previousStep(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            _buildProgressBar(),
            
            // Content
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            
            // Proceed Button
            _buildProceedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Obx(() {
        double progress = (controller.currentStep.value + 1) / 3;
        return Stack(
          children: [
            Container(
              height: 4.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4.h,
              width: (ScreenUtil().screenWidth - 48.w) * progress,
              decoration: BoxDecoration(
                color: const Color(0xFF800000), // Maroon
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProceedButton() {
    return Obx(() => Padding(
          padding: EdgeInsets.all(24.w),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.canProceed ? () => controller.nextStep() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Proceed',
                style: TextStyle(
                  color: controller.canProceed ? Colors.white : Colors.grey[600],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildStep2() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            'Which category do you belong to?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 24.h),
          ...controller.categories.map((category) => Obx(() => _buildRadioOption(
                title: category,
                value: category,
                groupValue: controller.selectedCategory.value,
                onChanged: (val) => controller.selectCategory(val!),
              ))),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            'Which partner are you seeking?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 24.h),
          ...controller.partners.map((partner) => Obx(() => _buildRadioOption(
                title: partner,
                value: partner,
                groupValue: controller.selectedPartner.value,
                onChanged: (val) => controller.selectPartner(val!),
              ))),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            'Select the country/ countries you wish to connect with partners from',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'You can select more than one country where your partners from',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blueGrey[400],
            ),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: () => _showCountryPicker(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => Text(
                          controller.selectedCountries.isEmpty
                              ? 'Country'
                              : controller.selectedCountries.join(', '),
                          style: TextStyle(
                            color: controller.selectedCountries.isEmpty
                                ? Colors.grey[400]
                                : Colors.black87,
                            fontSize: 15.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.blueGrey[800],
          ),
        ),
        activeColor: const Color(0xFF800000),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  void _showCountryPicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Select Countries',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                itemCount: controller.availableCountries.length,
                itemBuilder: (context, index) {
                  final country = controller.availableCountries[index];
                  return Obx(() => CheckboxListTile(
                        value: controller.selectedCountries.contains(country),
                        onChanged: (_) => controller.toggleCountry(country),
                        title: Text(country),
                        activeColor: const Color(0xFF800000),
                      ));
                },
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
