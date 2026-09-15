import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/add_creator_controller.dart';
import '../../../core/values/app_colors.dart';

class AddCreatorView extends GetView<AddCreatorController> {
  const AddCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Creator',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _buildTextField(
              controller: controller.usernameController,
              label: 'Creator Username',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.emailController,
              label: 'Creator Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (!GetUtils.isEmail(v)) return 'Invalid email';
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildDropdown(
              label: 'Talent Type',
              value: controller.talentType,
              items: ['actor', 'model', 'influencer'],
            ),
            SizedBox(height: 16.h),
            _buildDropdown(
              label: 'Company Type',
              value: controller.companyType,
              items: ['individual', 'company'],
            ),
            SizedBox(height: 16.h),
            _buildDropdown(
              label: 'Management Type',
              value: controller.managementType,
              items: ['affiliate', 'content_creator'],
            ),
            SizedBox(height: 16.h),
            _buildDatePicker(context),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.commentsController,
              label: 'Add Comments',
              maxLines: 3,
            ),
            SizedBox(height: 32.h),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Add Creator',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<String> items,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: value.value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        items: items
            .map(
              (e) =>
                  DropdownMenuItem(value: e, child: Text(e.capitalizeFirst!)),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) value.value = v;
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => controller.pickStartDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                controller.managementStartDate.value == null
                    ? 'Management Start Date'
                    : 'Start Date: ${DateFormat('yyyy-MM-dd').format(controller.managementStartDate.value!)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: controller.managementStartDate.value == null
                      ? Colors.grey[700]
                      : Colors.black,
                ),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
