import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationFormWidget extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPickFile;
  final VoidCallback onSubmit;
  final String? fileName;

  const VerificationFormWidget({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPickFile,
    required this.onSubmit,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              _buildCheckItem("National ID"),
              SizedBox(height: 10.h),
              _buildCheckItem("Passport"),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: onPickFile,
          child: Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, size: 40.sp, color: const Color(0xFF333333)),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    fileName ?? "Attach ID",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.only(left: 45.w),
          child: Text(
            "Upload",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF28A745),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1D1D),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonText,
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
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: const Color(0xFF28A745), size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
