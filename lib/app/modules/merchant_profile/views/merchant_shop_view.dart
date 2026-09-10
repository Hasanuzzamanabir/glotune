import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_profile_controller.dart';
import '../../../data/models/shop_item.dart';

class MerchantShopView extends GetView<MerchantProfileController> {
  const MerchantShopView({super.key});

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
          "Merchant shop",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildShopCategoryBar(),
          _buildShopSearchBar(),
          Expanded(child: _buildShopGrid()),
        ],
      ),
    );
  }

  Widget _buildShopCategoryBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Obx(() {
        if (controller.isCategoriesLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: controller.shopCategories.map((cat) {
              bool isSelected = controller.selectedShopCategory.value == cat;
              return GestureDetector(
                onTap: () => controller.selectShopCategory(cat),
                child: Container(
                  margin: EdgeInsets.only(right: 20.w),
                  padding: EdgeInsets.only(bottom: 4.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xFF8B1D1D)
                            : Colors.transparent,
                        width: 2.h,
                      ),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF8B1D1D) : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildShopSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(Icons.search, color: Colors.grey, size: 24.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      onChanged: controller.updateShopSearchQuery,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Obx(() {
            final hasFilters =
                controller.minPriceFilter.value != null ||
                controller.maxPriceFilter.value != null ||
                controller.sortBy.value != "Default" ||
                controller.onSaleOnly.value ||
                controller.countyFilter.value.isNotEmpty ||
                controller.cityFilter.value.isNotEmpty;

            return GestureDetector(
              onTap: () => _showFilterBottomSheet(Get.context!),
              child: Container(
                height: 48.h,
                width: 48.h,
                decoration: BoxDecoration(
                  color: hasFilters ? Colors.orange : const Color(0xFF8B1D1D),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.tune, color: Colors.white, size: 24.sp),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShopGrid() {
    return Obx(() {
      if (controller.isProductsLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF8B1D1D)));
      }
      final items = controller.filteredShopItems;
      if (items.isEmpty) {
        return Center(
          child: Text(
            "No products found.",
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!controller.isFetchingMore.value &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            controller.fetchShopItems();
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i += 2)
                          _buildShopItemCard(items[i], i % 4 == 0 ? 250.h : 200.h),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Right Column
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 1; i < items.length; i += 2)
                          _buildShopItemCard(items[i], i % 4 == 1 ? 200.h : 250.h),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.isFetchingMore.value)
                Padding(
                  padding: EdgeInsets.all(16.h),
                  child: const CircularProgressIndicator(color: Color(0xFF8B1D1D)),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildShopItemCard(ShopItem item, double imageHeight) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-details', arguments: item),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              item.title,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  item.price,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (item.originalPrice != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    item.originalPrice!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    double tempMinPrice = controller.minPriceFilter.value ?? 0.0;
    double tempMaxPrice = controller.maxPriceFilter.value ?? 500.0;
    if (tempMaxPrice < tempMinPrice) tempMaxPrice = tempMinPrice + 100;

    String tempSortBy = controller.sortBy.value;
    bool tempOnSaleOnly = controller.onSaleOnly.value;
    
    // We can use TextEditingControllers to manage text input state inside the bottom sheet
    TextEditingController countyController = TextEditingController(text: controller.countyFilter.value);
    TextEditingController cityController = TextEditingController(text: controller.cityFilter.value);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearShopFilters();
                        Get.back();
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  "Sort By",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  children:
                      [
                        "Default",
                        "Price: Low to High",
                        "Price: High to Low",
                      ].map((sortOption) {
                        return ChoiceChip(
                          label: Text(sortOption),
                          selected: tempSortBy == sortOption,
                          onSelected: (selected) {
                            setState(() {
                              tempSortBy = sortOption;
                            });
                          },
                          selectedColor: const Color(0xFF8B1D1D).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: tempSortBy == sortOption
                                ? const Color(0xFF8B1D1D)
                                : Colors.black,
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Price Range",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RangeSlider(
                  values: RangeValues(tempMinPrice, tempMaxPrice),
                  min: 0.0,
                  max: 1000.0,
                  divisions: 20,
                  labels: RangeLabels(
                    "\$${tempMinPrice.toInt()}",
                    "\$${tempMaxPrice.toInt()}",
                  ),
                  activeColor: const Color(0xFF8B1D1D),
                  onChanged: (RangeValues values) {
                    setState(() {
                      tempMinPrice = values.start;
                      tempMaxPrice = values.end;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$${tempMinPrice.toInt()}"),
                    Text("\$${tempMaxPrice.toInt()}"),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "On Sale Only",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: tempOnSaleOnly,
                      activeThumbColor: const Color(0xFF8B1D1D),
                      onChanged: (val) {
                        setState(() {
                          tempOnSaleOnly = val;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: countyController,
                  decoration: InputDecoration(
                    labelText: "County",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1D1D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      controller.applyShopFilters(
                        min: tempMinPrice,
                        max: tempMaxPrice,
                        sort: tempSortBy,
                        sale: tempOnSaleOnly,
                        county: countyController.text.trim(),
                        city: cityController.text.trim(),
                      );
                      Get.back();
                    },
                    child: Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
