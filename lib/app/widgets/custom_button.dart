import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/values/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String? iconPath;
  final bool isOutlined;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconPath,
    this.isOutlined = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : (backgroundColor ?? AppColors.primary),
          foregroundColor: textColor ?? (isOutlined ? AppColors.textPrimary : Colors.white),
          elevation: isOutlined ? 0 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: isOutlined ? const BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              iconPath!.toLowerCase().endsWith('.svg')
                  ? SvgPicture.asset(
                      iconPath!,
                      width: 24.w,
                      height: 24.w,
                    )
                  : Image.asset(
                      iconPath!,
                      width: 24.w,
                      height: 24.w,
                    ),
              SizedBox(width: 12.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
