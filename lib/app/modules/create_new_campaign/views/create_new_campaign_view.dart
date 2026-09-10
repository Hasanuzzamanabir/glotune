import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/create_new_campaign_controller.dart';

class CreateNewCampaignView extends GetView<CreateNewCampaignController> {
  const CreateNewCampaignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create new campaign',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            children: [
              _buildTextField('Campaign Title'),
              SizedBox(height: 12.h),
              _buildTextField('Start date', icon: Icons.calendar_today_rounded),
              SizedBox(height: 12.h),
              _buildTextField('End date', icon: Icons.calendar_today_rounded),
              SizedBox(height: 12.h),
              _buildTextField('Campaign cost'),
              SizedBox(height: 12.h),
              _buildTextField('Managed by', icon: Icons.keyboard_arrow_down_rounded),
              SizedBox(height: 12.h),
              _buildTextField('Creators @ usernames'),
              SizedBox(height: 12.h),
              _buildTextField('Commission %'),
              SizedBox(height: 12.h),
              _buildTextField('Expected deliverables'),
              SizedBox(height: 12.h),
              _buildTextField('Expected ROI'),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.cloud_upload_rounded, color: Colors.black87, size: 20.sp),
                  label: Text(
                    'Upload media assets',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    side: const BorderSide(color: Colors.black87),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1D1D),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          suffixIcon: icon != null
              ? Icon(icon, color: Colors.black87, size: 20.sp)
              : null,
        ),
      ),
    );
  }
}
