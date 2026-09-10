import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
        ),
        title: Text(
          "Product details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 24.sp),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.ios_share, color: Colors.black, size: 24.sp),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildProductInfo(),
            _buildBuyButton(),
            _buildDivider(),
            _buildSizeSelection(),
            _buildColorSelection(),
            _buildDivider(),
            _buildShippingDetails(),
            _buildDivider(),
            _buildYouMayAlsoLike(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 350.h,
          color: const Color(0xFFF8F8F8),
          child: PageView.builder(
            itemCount: controller.imageUrls.length,
            onPageChanged: controller.onImagePageChanged,
            itemBuilder: (context, index) {
              return Image.network(
                controller.imageUrls[index],
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.imageUrls.length,
            (index) {
              final isActive = controller.currentImageIndex.value == index;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                width: isActive ? 32.w : 12.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF8B1D1D) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            },
          ),
        )),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final details = controller.productDetails;
        
        final priceStr = details['price']?.toString();
        final discountStr = details['discount_price']?.toString();
        
        final hasDiscount = discountStr != null && discountStr.isNotEmpty && double.tryParse(discountStr) != null && double.parse(discountStr) > 0;
        
        final mainPriceStr = hasDiscount ? discountStr : priceStr;
        final originalPriceStr = hasDiscount ? priceStr : null;

        final title = details['name'] as String? ?? controller.item.title;
        final price = mainPriceStr ?? controller.item.price.replaceAll('\$', '');
        final originalPrice = originalPriceStr ?? controller.item.originalPrice?.replaceAll('\$', '');
        
        final status = details['product_status'] as String?;
        final sku = details['sku'] as String?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text("4.5 ratings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    SizedBox(width: 4.w),
                    Text("(102 Sold)", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 16.sp),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  "\$$price",
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                if (originalPrice != null && originalPrice.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Text(
                    "\$$originalPrice",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey, decoration: TextDecoration.lineThrough),
                  ),
                ],
              ],
            ),
            if (status != null) ...[
              SizedBox(height: 8.h),
              Text(
                "Status: ${status.replaceAll('_', ' ')}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: status == 'out_of_stock' ? Colors.red : Colors.green,
                ),
              ),
            ],
            if (sku != null && sku.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                "SKU: $sku",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
            if (details['description'] != null && details['description'].toString().isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Text(
                  details['description'],
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildBuyButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Obx(() {
        final status = controller.productDetails['product_status'] as String?;
        final isOutOfStock = status == 'out_of_stock';

        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutOfStock ? Colors.grey : const Color(0xFF8B1D1D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
            ),
            onPressed: isOutOfStock ? null : () {},
            child: Text(
              isOutOfStock ? "Out of Stock" : "Buy Now", 
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1));
  }

  Widget _buildSizeSelection() {
    final sizes = ['Small', 'Medium', 'Large', 'XXL'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Size", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Obx(() => Wrap(
            spacing: 12.w,
            children: sizes.map((size) {
              final isSelected = controller.selectedSize.value == size;
              return GestureDetector(
                onTap: () => controller.selectSize(size),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[200] : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: isSelected ? Colors.grey[400]! : Colors.transparent),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    final colors = [
      const Color(0xFF0F1A2C), // Dark Blue
      const Color(0xFFFFAE96), // Peach
      const Color(0xFF1F4E79), // Blue
      const Color(0xFF2C2C2C), // Dark Grey
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Color", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Obx(() => Row(
            children: List.generate(colors.length, (index) {
              final isSelected = controller.selectedColorIndex.value == index;
              return GestureDetector(
                onTap: () => controller.selectColor(index),
                child: Container(
                  margin: EdgeInsets.only(right: 12.w),
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(6.r),
                    border: isSelected ? Border.all(color: Colors.orange, width: 2) : null,
                  ),
                ),
              );
            }),
          )),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Obx(() {
      final shipping = controller.productDetails['shipping_details'] as String?;
      String displayShipping = "Check shipping options";
      if (shipping == 'free_shipment') displayShipping = "Free Shipping";
      if (shipping == 'paid_shipment') displayShipping = "Paid Shipping";
      if (shipping == 'no_shipment') displayShipping = "No Shipping";
      
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        title: Text(
          displayShipping,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        subtitle: Text(
          "Shipping details",
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
        trailing: Icon(Icons.local_shipping_outlined, color: Colors.black, size: 20.sp),
        onTap: () {},
      );
    });
  }

  Widget _buildYouMayAlsoLike() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text("You may also like", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 180.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: 120.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Image.network("https://picsum.photos/150/150?random=${index + 20}", fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text("T-shirt", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      SizedBox(height: 4.h),
                      Text("\$14", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
