import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/inventory_management_controller.dart';

class InventoryManagementView extends GetView<InventoryManagementController> {
  const InventoryManagementView({super.key});

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
          'My Inventory',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          children: [
            _buildStatsCard(),
            SizedBox(height: 20.h),
            _buildProductList(),
            SizedBox(height: 20.h),
            _buildShowMore(),
            SizedBox(height: 30.h),
            _buildAddProductButton(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("12", "Total Products", onTap: () => Get.toNamed(Routes.TOTAL_PRODUCTS)),
          _buildStatDivider(),
          _buildStatItem("4", "Sold", onTap: () => Get.toNamed(Routes.SOLD_PRODUCTS)),
          _buildStatDivider(),
          _buildStatItem("8", "Active Listings", onTap: () => Get.toNamed(Routes.ACTIVE_LISTINGS)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E232C)),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40.h,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildProductList() {
    final products = [
      {
        "name": "Crunches",
        "desc": "Crunchy, tasty snack made from toasted grains and seeds......",
        "price": "\$250.00",
        "stock": "In Stock",
        "img": "https://picsum.photos/100/100?random=1"
      },
      {
        "name": "Headset",
        "desc": "High-quality headset with clear sound and comfortable fit....",
        "price": "\$250.00",
        "stock": "Sold Out",
        "img": "https://picsum.photos/100/100?random=2"
      },
      {
        "name": "Macbook 2025",
        "desc": "Compact and powerful laptop with fast performance and....",
        "price": "\$250.00",
        "stock": "Sold Out",
        "img": "https://picsum.photos/100/100?random=3"
      },
      {
        "name": "Macbook 2025",
        "desc": "Compact and powerful laptop with fast performance and....",
        "price": "\$250.00",
        "stock": "In Stock",
        "img": "https://picsum.photos/100/100?random=4"
      },
      {
        "name": "Headset",
        "desc": "High-quality headset with clear sound and comfortable fit....",
        "price": "\$250.00",
        "stock": "In Stock",
        "img": "https://picsum.photos/100/100?random=5"
      },
      {
        "name": "Headset",
        "desc": "High-quality headset with clear sound and comfortable fit....",
        "price": "\$250.00",
        "stock": "In Stock",
        "img": "https://picsum.photos/100/100?random=6"
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(
          name: product["name"]!,
          desc: product["desc"]!,
          price: product["price"]!,
          status: product["stock"]!,
          imageUrl: product["img"]!,
        );
      },
    );
  }

  Widget _buildProductCard({
    required String name,
    required String desc,
    required String price,
    required String status,
    required String imageUrl,
  }) {
    bool inStock = status == "In Stock";
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              imageUrl,
              height: 60.w,
              width: 60.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: inStock ? Colors.grey.withOpacity(0.1) : Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: inStock ? Colors.grey[700] : Colors.red[300],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowMore() {
    return Column(
      children: [
        Text(
          "Show More Products",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () => Get.toNamed(Routes.ADD_NEW_PRODUCT),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B1D1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "Add New Product",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
