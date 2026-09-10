import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/shop_item.dart';
import 'package:glotune/app/data/models/content_list.dart';
import 'package:glotune/app/data/models/live_room.dart';
import 'package:glotune/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final selectedCategory = "All".obs;
  
  final RxString userType = "".obs;
  final RxString userAvatarUrl = "".obs;
  final RxBool isProfileLoading = false.obs;
  final RxInt unreadNotificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchUnreadNotificationCount();
    fetchShopCategories();
    fetchShopItems(isRefresh: true);
    fetchContentList(isRefresh: true);
    fetchLiveRooms(isRefresh: true);
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchContentList(isRefresh: true),
      fetchShopItems(isRefresh: true),
      fetchLiveRooms(isRefresh: true),
      fetchUserProfile(),
    ]);
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;
      
      final headers = {'Authorization': 'Bearer $token'};
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}notifications/unread/count/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // It could be a simple {"count": 5} or {"unread_count": 5} or paginated format
        unreadNotificationCount.value = data['count'] ?? data['unread_count'] ?? 0;
      }
    } catch (e) {
      print("Error fetching unread notification count: $e");
    }
  }

  Future<void> fetchUserProfile() async {
    isProfileLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}auth/profile/me/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userType.value = data['user_type'] ?? "";
        userAvatarUrl.value = data['profile_picture_url'] ?? data['profile_picture'] ?? data['avatar'] ?? "";
      } else {
        print("Failed to fetch profile: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isProfileLoading.value = false;
    }
  }

  // Top pill tabs (Videos / Live / Friends / Shop)
  final topTabs = ["Videos", "Live", "Friends", "Shop"];
  final selectedTopTab = "Videos".obs;

  // Category chips under the pill
  final categories = [
    "All",
    "News",
    "Short",
    "Entertainment",
    "Podcast",
    "Music",
  ];

  // Shop Categories
  final shopCategories = <String>[].obs;
  final selectedShopCategory = "".obs;
  final shopSearchQuery = "".obs;
  final isShopCategoriesLoading = false.obs;

  Future<void> fetchShopCategories() async {
    isShopCategoriesLoading.value = true;
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
      isShopCategoriesLoading.value = false;
    }
  }

  // Filter States
  final minPriceFilter = Rx<double?>(null);
  final maxPriceFilter = Rx<double?>(null);
  final sortBy = "Default".obs; // "Default", "Price: Low to High", "Price: High to Low"
  final onSaleOnly = false.obs;
  final countyFilter = "".obs;
  final cityFilter = "".obs;

  // Shop Items
  final shopItems = <ShopItem>[].obs;
  final isShopItemsLoading = false.obs;

  // Pagination vars
  final currentPage = 1.obs;
  final hasMoreItems = true.obs;
  final isFetchingMore = false.obs;

  Future<void> fetchShopItems({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreItems.value = true;
      isShopItemsLoading.value = true;
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
        isShopItemsLoading.value = false;
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

  // Content List
  final allContent = <ContentList>[].obs;
  final isContentLoading = false.obs;
  final contentCurrentPage = 1.obs;
  final contentHasMoreItems = true.obs;
  final isContentFetchingMore = false.obs;
  
  // Live Rooms
  final liveRooms = <LiveRoom>[].obs;
  final isLiveRoomsLoading = false.obs;
  final liveRoomsCurrentPage = 1.obs;
  final liveRoomsHasMoreItems = true.obs;
  final isLiveRoomsFetchingMore = false.obs;

  Future<void> fetchLiveRooms({bool isRefresh = false}) async {
    if (isRefresh) {
      liveRoomsCurrentPage.value = 1;
      liveRoomsHasMoreItems.value = true;
      isLiveRoomsLoading.value = true;
    } else {
      if (!liveRoomsHasMoreItems.value || isLiveRoomsFetchingMore.value) return;
      isLiveRoomsFetchingMore.value = true;
    }

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}live/public-rooms/?page=${liveRoomsCurrentPage.value}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        
        final items = results.map((e) => LiveRoom.fromJson(e)).toList();

        if (isRefresh) {
          liveRooms.value = items;
        } else {
          liveRooms.addAll(items);
        }

        if (data['next'] != null) {
          liveRoomsCurrentPage.value++;
        } else {
          liveRoomsHasMoreItems.value = false;
        }
      }
    } catch (e) {
      print("Error fetching live rooms: $e");
    } finally {
      if (isRefresh) {
        isLiveRoomsLoading.value = false;
      } else {
        isLiveRoomsFetchingMore.value = false;
      }
    }
  }

  Future<void> fetchContentList({bool isRefresh = false}) async {
    if (isRefresh) {
      contentCurrentPage.value = 1;
      contentHasMoreItems.value = true;
      isContentLoading.value = true;
    } else {
      if (!contentHasMoreItems.value || isContentFetchingMore.value) return;
      isContentFetchingMore.value = true;
    }

    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}content/list/public/?page=${contentCurrentPage.value}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        
        final items = results.map((e) => ContentList.fromJson(e)).toList();

        if (isRefresh) {
          allContent.value = items;
        } else {
          allContent.addAll(items);
        }

        if (data['next'] != null) {
          contentCurrentPage.value++;
        } else {
          contentHasMoreItems.value = false;
        }
      }
    } catch (e) {
      print("Error fetching content list: $e");
    } finally {
      if (isRefresh) {
        isContentLoading.value = false;
      } else {
        isContentFetchingMore.value = false;
      }
    }
  }

  List<ContentList> get filteredVideos {
    return allContent.where((content) {
      // Logic for filtering based on top tabs (e.g. "Live" -> "Live Streams")
      bool matchesTab = true;
      if (selectedTopTab.value == "Live") {
        matchesTab = content.categoryName?.toLowerCase().contains("live") ?? false;
      } else if (selectedTopTab.value == "Videos") {
        // Show all videos in the 'Videos' tab, or filter out actual live streams if we have a way to know
        // For now, let's just show everything in Videos so it's not empty, 
        // or specifically allow them if contentType is video/shorts
        matchesTab = content.contentType != 'live'; 
      }

      // Filtering based on category chips
      bool matchesCategory = true;
      if (selectedCategory.value != "All") {
        if (selectedCategory.value == "Short") {
          matchesCategory = content.contentType == "shorts";
        } else {
          matchesCategory = content.categoryName == selectedCategory.value;
        }
      }
      return matchesTab && matchesCategory;
    }).toList();
  }

  void selectTopTab(String tab) => selectedTopTab.value = tab;

  void changeIndex(int index) {
    if (index == 2) {
      Get.toNamed(Routes.CREATE);
    } else {
      currentIndex.value = index;
    }
  }
  
  void selectCategory(String category) => selectedCategory.value = category;

  void selectShopCategory(String category) => selectedShopCategory.value = category;

  void updateShopSearchQuery(String query) => shopSearchQuery.value = query;

  void applyShopFilters({double? min, double? max, String? sort, bool? sale, String? county, String? city}) {
    minPriceFilter.value = min;
    maxPriceFilter.value = max;
    if (sort != null) sortBy.value = sort;
    if (sale != null) onSaleOnly.value = sale;
    if (county != null) countyFilter.value = county;
    if (city != null) cityFilter.value = city;
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
