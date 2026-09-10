import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/services/interaction_service.dart';
import 'package:glotune/app/core/values/app_colors.dart';

class ReportUtils {
  static void showReportUserDialog(int userId) {
    String selectedType = 'harassment_or_bullying';
    final reasonController = TextEditingController();
    final isSubmitting = false.obs;

    final Map<String, String> reportTypes = {
      'hate_speech': 'Hate Speech',
      'violent_or_threatening_behavior': 'Violent or Threatening Behavior',
      'fraudulent_activity': 'Fraudulent Activity',
      'dangerous_or_risky_acts': 'Dangerous or Risky Acts',
      'graphic_or_disturbing_content': 'Graphic or Disturbing Content',
      'harassment_or_bullying': 'Harassment or Bullying',
      'false_or_misleading_information': 'False or Misleading Information',
      'sexual_and_inappropriate_content': 'Sexual & Inappropriate Content',
      'self_harm_or_suicide_behavior': 'Self-Harm or Suicide Behavior',
    };

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  SizedBox(height: 20.h),
                  Text("Report User", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 8.h),
                  Text("Please select a reason and provide details.", style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  SizedBox(height: 20.h),
                  Text("Report Type", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: reportTypes.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => selectedType = newValue);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text("Reason", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Provide additional details...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: Obx(() => ElevatedButton(
                      onPressed: isSubmitting.value ? null : () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          Get.snackbar("Required", "Please provide a reason for reporting.", backgroundColor: Colors.white, colorText: Colors.black);
                          return;
                        }
                        
                        isSubmitting.value = true;
                        final service = Get.find<InteractionService>();
                        final success = await service.reportUser(userId, selectedType, reason);
                        isSubmitting.value = false;
                        
                        if (success) {
                          Get.back();
                          Get.snackbar("Report Submitted", "Thank you for keeping our community safe.", backgroundColor: Colors.white, colorText: Colors.black);
                        } else {
                          Get.snackbar("Error", "Failed to submit report. Please try again.", backgroundColor: Colors.white, colorText: Colors.black);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: isSubmitting.value 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Submit Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
