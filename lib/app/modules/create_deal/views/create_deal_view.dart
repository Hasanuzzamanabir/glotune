import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/create_deal_controller.dart';

class CreateDealView extends GetView<CreateDealController> {
  const CreateDealView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create new deal",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildDropdownField("Creators @usernames"),
            SizedBox(height: 16.h),
            _buildTextField("Brand / Sponsor /Companies"),
            SizedBox(height: 16.h),
            _buildTextField("Deal Value"),
            SizedBox(height: 16.h),
            _buildDropdownField("Expected ROI"),
            SizedBox(height: 16.h),
            _buildDateField("Start date"),
            SizedBox(height: 16.h),
            _buildDateField("End date"),
            SizedBox(height: 16.h),
            _buildDropdownField("Payment Terms"),
            SizedBox(height: 24.h),
            _buildChecklistSection(
              title: "KPI to Track",
              items: [
                "Creators Managed",
                "Active Deals",
                "Pending Proposals",
                "ROI Across Creators",
                "Total Sponsorship Value",
              ],
            ),
            SizedBox(height: 24.h),
            _buildChecklistSection(
              title: "Deliverables",
              items: [
                "Creators Managed",
                "Active Deals",
                "Pending Proposals",
                "ROI Across Creators",
              ],
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1D1D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  "Add new deal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        items: const [], // Empty for UI purposes
        onChanged: (val) {},
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 24.sp),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildDateField(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.black87, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildChecklistSection({required String title, required List<String> items}) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black),
          ),
          SizedBox(height: 16.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 14.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  item,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
