import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/proposal_details_controller.dart';

class ProposalDetailsView extends GetView<ProposalDetailsController> {
  const ProposalDetailsView({super.key});

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
          "Proposal details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: const CachedNetworkImageProvider("https://picsum.photos/100/100?random=5"),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Cameron Williamson", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                SizedBox(width: 4.w),
                                Icon(Icons.military_tech, color: Colors.orange, size: 16.sp),
                              ],
                            ),
                            Text("@camwils34", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$500", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        Text("Budget", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Managed pill
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B1D1D).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Text(
                      "Managed 50+ creators, facilitated 120+ paid deals",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8B1D1D),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Contract Details Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Contract proposal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black87)),
                      SizedBox(height: 16.h),
                      Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Benefit", style: TextStyle(color: Colors.blueGrey[300], fontSize: 13.sp, fontWeight: FontWeight.w500)),
                          Expanded(
                            child: Text(
                              "Sponsorship access,\nmonthly coaching",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Type", style: TextStyle(color: Colors.blueGrey[300], fontSize: 13.sp, fontWeight: FontWeight.w500)),
                          Text("Exclusive", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF1E293B))),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Duration", style: TextStyle(color: Colors.blueGrey[300], fontSize: 13.sp, fontWeight: FontWeight.w500)),
                          Text("6 Months", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF1E293B))),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Divider(color: Colors.grey.withOpacity(0.2), height: 1),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: Colors.orange, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            "Download full contract details here",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          "Decline",
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B1D1D),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
