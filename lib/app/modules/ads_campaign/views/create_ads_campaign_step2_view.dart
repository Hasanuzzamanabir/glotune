import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/ads_campaign_controller.dart';
import 'package:intl/intl.dart';

class CreateAdsCampaignStep2View extends GetView<AdsCampaignController> {
  const CreateAdsCampaignStep2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ads Campaign',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Choose Target Audience'),
              Row(
                children: [
                  _buildAudienceToggle('Male'),
                  SizedBox(width: 12.w),
                  _buildAudienceToggle('Female'),
                ],
              ),
              SizedBox(height: 24.h),
              
              _buildDropdown('Choose Country', controller.country, ['USA', 'UK', 'Canada', 'Australia']),
              SizedBox(height: 12.h),
              _buildDropdown('Select City / Province', controller.city, ['New York', 'London', 'Toronto', 'Sydney']),
              SizedBox(height: 12.h),
              _buildDropdown('Select Language', controller.language, ['English', 'Spanish', 'French', 'German']),
              SizedBox(height: 24.h),

              _buildLabel('Campaign Duration'),
              Row(
                children: [
                  Expanded(child: _buildDateField('Start Date', controller.startDate, context)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildDateField('End Date', controller.endDate, context)),
                ],
              ),
              SizedBox(height: 24.h),

              _buildLabel('Frequency'),
              _buildDropdown('Choose', controller.frequency, [
                'Daily',
                'Every 2 Days',
                'Every 3 Days',
                'Every 4 Days',
                'Every 5 Days',
                'Every 6 Days',
                'Weekly',
                'Ocassionally'
              ], dropdownColor: const Color(0xFFF7FBFF)),
              SizedBox(height: 24.h),

              _buildLabel('Campaign Cost'),
              _buildCostField(),
              SizedBox(height: 24.h),

              _buildLabel('Payment Options'),
              _buildRadioList(controller.selectedPaymentMethod, ['credit_card', 'debit_card']),
              SizedBox(height: 24.h),

              _buildLabel('Budget Settings'),
              Row(
                children: [
                  Expanded(child: _buildRadioOption(controller.budgetSetting, 'Fixed')),
                  Expanded(child: _buildRadioOption(controller.budgetSetting, 'Daily Spend Cap')),
                ],
              ),
              SizedBox(height: 32.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('View Invoice', style: TextStyle(color: Colors.blue, fontSize: 14.sp)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Download Invoice', style: TextStyle(color: Colors.blue, fontSize: 14.sp)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPillButton('Edit'),
                  _buildPillButton('Save'),
                  _buildPillButton('Preview'),
                ],
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.submitCampaign(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSubmitting.value 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Publish',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                )),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAudienceToggle(String label) {
    return Obx(() {
      final isSelected = controller.targetAudience.value == label;
      return GestureDetector(
        onTap: () => controller.targetAudience.value = label,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDropdown(String hint, Rx<String?> rxValue, List<String> items, {Color? dropdownColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            value: rxValue.value,
            hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
            dropdownColor: dropdownColor ?? Colors.white,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
              );
            }).toList(),
            onChanged: (value) {
              rxValue.value = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, Rx<DateTime?> rxDate, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              rxDate.value = date;
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Obx(() {
              final val = rxDate.value;
              return Text(
                val != null ? DateFormat('dd/MM/yyyy').format(val) : 'DD/MM/YYYY',
                style: TextStyle(
                  color: val != null ? Colors.black87 : Colors.grey[400],
                  fontSize: 14.sp,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: controller.costController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: '\$0.00',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildRadioList(Rx<String?> rxValue, List<String> options) {
    return Column(
      children: options.map((option) => _buildRadioOption(rxValue, option)).toList(),
    );
  }

  Widget _buildRadioOption(Rx<String?> rxValue, String label) {
    return Obx(() {
      final isSelected = rxValue.value == label;
      return InkWell(
        onTap: () => rxValue.value = label,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : Colors.grey[500],
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPillButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
