import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import '../../../data/models/shop_item.dart';

class ProductDetailsController extends GetxController {
  late final ShopItem item;
  final selectedSize = 'Small'.obs;
  final selectedColorIndex = 0.obs;
  
  late final List<String> imageUrls;
  final currentImageIndex = 0.obs;
  
  final productDetails = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Assuming the ShopItem is passed via Get.arguments
    if (Get.arguments != null && Get.arguments is ShopItem) {
      item = Get.arguments as ShopItem;
    } else {
      // Fallback for testing/safety
      item = ShopItem(
        title: "Plain tees for young lad",
        price: "\$178",
        originalPrice: "\$220",
        imageUrl: "https://picsum.photos/400/500?random=1",
        category: "Clothings",
        priceValue: 178.0,
        originalPriceValue: 220.0,
      );
    }
    
    imageUrls = [
      item.imageUrl,
      "https://picsum.photos/400/500?random=101",
      "https://picsum.photos/400/500?random=102",
      "https://picsum.photos/400/500?random=103",
    ];

    if (item.id != null) {
      fetchProductDetails(item.id!);
    }
  }

  Future<void> fetchProductDetails(int id) async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}product/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        productDetails.value = jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching product details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
  }

  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }
}
