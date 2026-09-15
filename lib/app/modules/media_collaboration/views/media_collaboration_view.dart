import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/media_collaboration_controller.dart';

class MediaCollaborationView extends GetView<MediaCollaborationController> {
  const MediaCollaborationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1D1D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Collaborations",
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "All Collaborations",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  return DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    dataRowMinHeight: 60.h,
                    dataRowMaxHeight: 60.h,
                    horizontalMargin: 12.w,
                    columnSpacing: 30.w,
                    dividerThickness: 1,
                    border: TableBorder(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      left: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      right: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      horizontalInside: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      verticalInside: BorderSide.none,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Username",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "User Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Agreement Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Cost",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Start Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "End Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: controller.collaborations.map((collab) {
                      return DataRow(
                        cells: [
                          DataCell(Text(collab.username)),
                          DataCell(Text(collab.userType)),
                          DataCell(Text(collab.agreementType)),
                          DataCell(Text(collab.cost)),
                          DataCell(Text(collab.startDate)),
                          DataCell(Text(collab.endDate)),
                          DataCell(_buildStatusBadge(collab.status)),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color textColor;
    Color bgColor;

    switch (status) {
      case "Active":
        textColor = const Color(0xFF28A745);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case "Pending":
        textColor = const Color(0xFFFFC107);
        bgColor = const Color(0xFFFFF8E1);
        break;
      case "Completed":
        textColor = const Color(0xFFDC3545);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        textColor = Colors.grey;
        bgColor = Colors.grey.withValues(alpha: 0.2);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
