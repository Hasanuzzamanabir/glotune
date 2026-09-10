import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/affiliate_program_controller.dart';

class AffiliateProgramView extends GetView<AffiliateProgramController> {
  const AffiliateProgramView({super.key});

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
          "Affiliate program",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gray Background Container for stats
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 200.h,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }
              final data = controller.stats.value;
              if (data == null) {
                return Container(
                  height: 200.h,
                  alignment: Alignment.center,
                  child: const Text("No affiliate stats available"),
                );
              }

              return Container(
                width: double.infinity,
                color: const Color(0xFFF9F9F9),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.15,
                  children: [
                    _buildStatCard(Icons.assignment_turned_in_outlined, "Status", data.isActive ? "Enrolled" : "Not Enrolled"),
                    _buildStatCard(Icons.hub, "Affiliate Tier", data.planStatus ?? "None"),
                    _buildStatCard(Icons.account_balance_wallet_outlined, "Commission Earned", "\$${data.commissionEarned}"),
                    _buildStatCard(Icons.campaign_outlined, "Referral Count", data.referralsCount.toString()),
                  ],
                ),
              );
            }),
            
            // Upgrade Section
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                "Upgrade",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            
            SizedBox(
              height: 420.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildUpgradeCard(
                    tier: "Bronze",
                    price: "14",
                    description: "Perfect for starters",
                    features: [
                      "Access to exclusive dashboard",
                      "5% commission per referral",
                      "Affiliate badge on profile"
                    ],
                    onTap: () => controller.upgradeToTier("Bronze"),
                  ),
                  SizedBox(width: 16.w),
                  _buildUpgradeCard(
                    tier: "Silver",
                    price: "19",
                    description: "Perfect for starters",
                    features: [
                      "Access to exclusive dashboard",
                      "10% commission per referral",
                      "Affiliate badge on profile",
                      "Discounted merchandise"
                    ],
                    onTap: () => controller.upgradeToTier("Silver"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            
            // New Table Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "Affiliate Table for multiple companies",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                final data = controller.stats.value;
                if (data == null || data.affiliateTable.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text("No affiliate data available"),
                  );
                }
                return DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.transparent),
                  dataRowMinHeight: 65.h,
                  dataRowMaxHeight: 65.h,
                  horizontalMargin: 16.w,
                  columnSpacing: 40.w,
                  dividerThickness: 1,
                  border: TableBorder(
                    top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    left: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    right: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    horizontalInside: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    verticalInside: BorderSide.none,
                  ),
                  columns: [
                    DataColumn(label: Text("S/N", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                    DataColumn(label: Text("Company Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                    DataColumn(label: Text("Campaign Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                    DataColumn(label: Text("Commission", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                  ],
                  rows: data.affiliateTable.asMap().entries.map((entry) {
                    final index = entry.key;
                    final company = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text("${index + 1}", style: TextStyle(fontSize: 14.sp))),
                        DataCell(Text(company.companyName, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                        DataCell(Text(company.campaignName, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                        DataCell(Text("\$${company.commission}", style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8B1D1D).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: const Color(0xFF8B1D1D), size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.blueGrey[400],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard({
    required String tier,
    required String price,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    tier,
                    style: TextStyle(
                      color: const Color(0xFF8B1D1D),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$$price",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        "/month",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blueGrey[400],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1D1D),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Upgrade",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B1D1D),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
