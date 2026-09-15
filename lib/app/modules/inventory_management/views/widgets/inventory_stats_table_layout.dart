import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class InventoryStatsTableLayout extends StatelessWidget {
  final String title;

  const InventoryStatsTableLayout({super.key, required this.title});

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
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grid Section
            Container(
              color: const Color(0xFFF8F9FA),
              padding: EdgeInsets.all(16.w),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(Icons.local_offer, "Total Products", "1200"),
                  _buildStatCard(Icons.inventory_2, "Top Selling Items", "120"),
                  _buildStatCard(
                    Icons.notifications_active,
                    "Inventory Alerts",
                    "100",
                  ),
                  _buildStatCard(
                    Icons.account_balance_wallet,
                    "Total Revenue",
                    "\$4,000",
                  ),
                ],
              ),
            ),

            // Table Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Inventory Table",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDataTable(),
                ],
              ),
            ),
            SizedBox(height: 80.h), // space for fab
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8B1D1D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: const Color(0xFF8B1D1D), size: 20.sp),
          ),
          Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.white),
          dataRowColor: WidgetStateProperty.all(Colors.white),
          dividerThickness: 1,
          columnSpacing: 30.w,
          columns: [
            DataColumn(label: _buildColHeader("S/N")),
            DataColumn(label: _buildColHeader("Product Name")),
            DataColumn(label: _buildColHeader("SKU")),
            DataColumn(label: _buildColHeader("Stock")),
            DataColumn(label: _buildColHeader("Price")),
          ],
          rows: [
            _buildDataRow("1", "Red Wine", "RW101", "12", "\$20"),
            _buildDataRow("2", "Red Wine", "RW101", "12", "\$20"),
            _buildDataRow("3", "Pet Socks", "PS384", "31", "\$12"),
          ],
        ),
      ),
    );
  }

  Widget _buildColHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
        color: Colors.black87,
      ),
    );
  }

  DataRow _buildDataRow(
    String sn,
    String name,
    String sku,
    String stock,
    String price,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(sn, style: _rowTextStyle())),
        DataCell(Text(name, style: _rowTextStyle())),
        DataCell(Text(sku, style: _rowTextStyle())),
        DataCell(Text(stock, style: _rowTextStyle())),
        DataCell(Text(price, style: _rowTextStyle())),
      ],
    );
  }

  TextStyle _rowTextStyle() {
    return TextStyle(fontSize: 13.sp, color: Colors.black54);
  }
}
