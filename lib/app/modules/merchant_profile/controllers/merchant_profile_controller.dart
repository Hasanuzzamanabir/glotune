import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/shop_item.dart';

class MerchantProfileController extends GetxController {
  // Shop Categories
  final shopCategories = <String>[].obs;
  final selectedShopCategory = "".obs;
  final shopSearchQuery = "".obs;
  final isCategoriesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShopCategories();
    fetchShopItems(isRefresh: true);
  }

  Future<void> fetchShopCategories() async {
    isCategoriesLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}product/category/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        final categories = results.map((e) => e['name'] as String).toList();
        
        shopCategories.value = categories;
        if (categories.isNotEmpty) {
          selectedShopCategory.value = categories.first;
        }
      }
    } catch (e) {
      print("Error fetching shop categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // Filter States
  final minPriceFilter = Rx<double?>(null);
  final maxPriceFilter = Rx<double?>(null);
  final sortBy = "Default".obs; 
  final onSaleOnly = false.obs;
  final countyFilter = "".obs;
  final cityFilter = "".obs;

  final shopItems = <ShopItem>[].obs;
  final isProductsLoading = false.obs;

  // Pagination vars
  final currentPage = 1.obs;
  final hasMoreItems = true.obs;
  final isFetchingMore = false.obs;

  Future<void> fetchShopItems({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreItems.value = true;
      isProductsLoading.value = true;
    } else {
      if (!hasMoreItems.value || isFetchingMore.value) return;
      isFetchingMore.value = true;
    }

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}product/list/?page=${currentPage.value}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        
        final items = results.map((e) {
          final priceStr = e['price']?.toString() ?? '0';
          final discountStr = e['discount_price']?.toString();
          
          final hasDiscount = discountStr != null && discountStr.isNotEmpty && double.tryParse(discountStr) != null && double.parse(discountStr) > 0;
          
          final mainPriceStr = hasDiscount ? discountStr : priceStr;
          final originalPriceStr = hasDiscount ? priceStr : null;

          final mainPriceVal = double.tryParse(mainPriceStr) ?? 0.0;
          final originalPriceVal = originalPriceStr != null ? double.tryParse(originalPriceStr) : null;
          
          return ShopItem(
            id: e['id'] as int?,
            title: e['name'] as String? ?? 'Product',
            price: '\$$mainPriceStr',
            originalPrice: originalPriceStr != null ? '\$$originalPriceStr' : null,
            imageUrl: "https://picsum.photos/200/300?random=${e['id']}", // Dummy image for now
            category: e['category_name'] as String? ?? 'Unknown',
            priceValue: mainPriceVal,
            originalPriceValue: originalPriceVal,
          );
        }).toList();

        if (isRefresh) {
          shopItems.value = items;
        } else {
          shopItems.addAll(items);
        }

        if (data['next'] != null) {
          currentPage.value++;
        } else {
          hasMoreItems.value = false;
        }
      }
    } catch (e) {
      print("Error fetching shop items: $e");
    } finally {
      if (isRefresh) {
        isProductsLoading.value = false;
      } else {
        isFetchingMore.value = false;
      }
    }
  }

  List<ShopItem> get filteredShopItems {
    List<ShopItem> filtered = shopItems.where((item) {
      final matchesCategory = item.category == selectedShopCategory.value;
      final matchesSearch = shopSearchQuery.value.isEmpty ||
          item.title.toLowerCase().contains(shopSearchQuery.value.toLowerCase());
      
      final matchesMinPrice = minPriceFilter.value == null || item.priceValue >= minPriceFilter.value!;
      final matchesMaxPrice = maxPriceFilter.value == null || item.priceValue <= maxPriceFilter.value!;
      final matchesOnSale = !onSaleOnly.value || item.originalPriceValue != null;
      
      final matchesCounty = countyFilter.value.isEmpty || 
          (item.county != null && item.county!.toLowerCase().contains(countyFilter.value.toLowerCase()));
      final matchesCity = cityFilter.value.isEmpty || 
          (item.city != null && item.city!.toLowerCase().contains(cityFilter.value.toLowerCase()));

      return matchesCategory && matchesSearch && matchesMinPrice && matchesMaxPrice && matchesOnSale && matchesCounty && matchesCity;
    }).toList();

    if (sortBy.value == "Price: Low to High") {
      filtered.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (sortBy.value == "Price: High to Low") {
      filtered.sort((a, b) => b.priceValue.compareTo(a.priceValue));
    }

    return filtered;
  }

  void selectShopCategory(String category) {
    selectedShopCategory.value = category;
  }

  void updateShopSearchQuery(String query) {
    shopSearchQuery.value = query;
  }

  void applyShopFilters({
    required double min,
    required double max,
    required String sort,
    required bool sale,
    required String county,
    required String city,
  }) {
    minPriceFilter.value = min;
    maxPriceFilter.value = max;
    sortBy.value = sort;
    onSaleOnly.value = sale;
    countyFilter.value = county;
    cityFilter.value = city;
  }

  void clearShopFilters() {
    minPriceFilter.value = null;
    maxPriceFilter.value = null;
    sortBy.value = "Default";
    onSaleOnly.value = false;
    countyFilter.value = "";
    cityFilter.value = "";
  }
}
