import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/create_proposal_controller.dart';

class CreateProposalView extends GetView<CreateProposalController> {
  const CreateProposalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1D1D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create a proposal",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Add Username"),
            SizedBox(height: 8.h),
            _buildTextField(hint: "@purplespeed342"),
            SizedBox(height: 20.h),

            _buildLabel("Agreement Type"),
            SizedBox(height: 8.h),
            _buildDropdown(),
            SizedBox(height: 20.h),

            _buildLabel("Cost"),
            SizedBox(height: 8.h),
            _buildTextField(hint: "\$0.00"),
            SizedBox(height: 20.h),

            _buildDateRow("Set Start Date", true),
            SizedBox(height: 20.h),
            _buildDateRow("Set End Date", false),
            SizedBox(height: 20.h),

            _buildLabel("Add Comment"),
            SizedBox(height: 8.h),
            _buildTextField(
              hint: "Lorem hgjudjasbjcknsdcdnkcb.......",
              maxLines: 4,
            ),
            SizedBox(height: 20.h),

            _buildLabel("Upload Proposal"),
            SizedBox(height: 8.h),
            _buildUploadBox(),
            SizedBox(height: 40.h),

            _buildSendButton(),
            SizedBox(height: 16.h),
            _buildDownloadButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: const BorderSide(color: Color(0xFF8B1D1D)),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(
              "Choose",
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
            value: controller.agreementType.value,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items: controller.agreementTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
              );
            }).toList(),
            onChanged: controller.setAgreementType,
          ),
        ),
      );
    });
  }

  Widget _buildDateRow(String label, bool isStart) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          if (isStart) {
            controller.setStartDate(date);
          } else {
            controller.setEndDate(date);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final date = isStart
                ? controller.startDate.value
                : controller.endDate.value;
            final text = date != null
                ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                : label;
            return Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            );
          }),
          Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: controller.pickFile,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_upload_rounded,
              color: const Color(0xFF333333),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Flexible(
              child: Obx(() {
                return Text(
                  controller.uploadedFileName.value ?? "MP4, JPG, PNG, WEBP",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B1D1D),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r), // pill shape
          ),
          elevation: 0,
        ),
        child: Text(
          "Send",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(
          Icons.file_download_outlined,
          color: const Color(0xFF8B1D1D),
          size: 20.sp,
        ),
        label: Text(
          "Download Proposal",
          style: TextStyle(
            color: const Color(0xFF8B1D1D),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: const BorderSide(color: Color(0xFF8B1D1D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }
}
