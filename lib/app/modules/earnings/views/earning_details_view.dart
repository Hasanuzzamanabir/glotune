import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EarningDetailsView extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> sections;

  const EarningDetailsView({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 4.h,
            color: const Color(0xFFF5F5F5),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return _buildSection(section);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final String sectionTitle = section['sectionTitle'];
    final double balance = section['balance'];
    final List<String> columns = section['columns'];
    final List<List<String>> rows = section['rows'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sectionTitle,
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${balance.toInt()}',
                    style: TextStyle(
                      color: const Color(0xFF2C3E50),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Available balance',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      return Expanded(
                        child: Text(
                          col,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Data rows
                ...rows.asMap().entries.map((entry) {
                  final int rowIndex = entry.key;
                  final List<String> row = entry.value;
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      border: rowIndex < rows.length - 1
                          ? Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.2)),
                            )
                          : null,
                    ),
                    child: Row(
                      children: row.map((cell) {
                        return Expanded(
                          child: Text(
                            cell,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 24.h), // Space between sections
        ],
      ),
    );
  }
}
