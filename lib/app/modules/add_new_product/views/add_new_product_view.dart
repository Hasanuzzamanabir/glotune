import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/add_new_product_controller.dart';

class AddNewProductView extends GetView<AddNewProductController> {
  const AddNewProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add New Product',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Product Name"),
            _buildTextField("Your Product Name"),

            SizedBox(height: 16.h),
            _buildLabel("Product Description"),
            _buildTextField("Compact and powerful......", maxLines: 4),

            SizedBox(height: 16.h),
            _buildLabel("Product Tag"),
            _buildWrapChips([
              "Brand New",
              "Limited Edition",
              "Discounted Sales",
              "Quality & Affordable",
            ], "Limited Edition"),

            SizedBox(height: 16.h),
            _buildLabel("Product Category"),
            _buildWrapChips([
              "Electronics",
              "Clothings",
              "Watches",
              "Stationeries",
              "Shoes",
              "Beverages",
              "Medicine",
              "Bags",
              "Furniture",
              "Phone & Accessories",
              "Book & Courses",
              "Construction Materials",
              "Others",
            ], "Beverages"),

            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildLabel("Price"), _buildTextField("\$0.00")],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("SKU"),
                      _buildTextField("TSJH7642964"),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            _buildLabel("Discount (%)"),
            _buildTextField("50%"),

            SizedBox(height: 16.h),
            _buildLabel("Product Images"),
            _buildImageUploadBox(),

            SizedBox(height: 16.h),
            _buildLabel("Shipping Details"),
            _buildWrapChips([
              "Free Shipment",
              "Paid Shipment",
              "No Shipment",
            ], "Paid Shipment"),

            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("Affiliate Promotion Allowed"),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: true,
                    onChanged: (v) {},
                    activeTrackColor: const Color(0xFF8B1D1D),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            _buildLabel("Set Affiliate Commission %"),
            _buildTextField("50%"),

            SizedBox(height: 16.h),
            _buildLabel("Select Local Market Presence Countries"),
            _buildDropdownField("Select Country"),

            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(child: _buildSecondaryButton("Edit")),
                SizedBox(width: 10.w),
                Expanded(child: _buildSecondaryButton("Save")),
                SizedBox(width: 10.w),
                Expanded(child: _buildSecondaryButton("Preview")),
              ],
            ),

            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1D1D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Publish",
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

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF8B1D1D)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: 24.sp,
          ),
          items: const [],
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildImageUploadBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload, color: const Color(0xFF8B1D1D), size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            "Upload",
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildWrapChips(List<String> items, String selected) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((item) {
        bool isSelected = item == selected;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B1D1D) : Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B1D1D)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSecondaryButton(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
