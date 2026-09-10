import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/favorite_content.dart';
import 'package:glotune/app/data/models/content_list.dart';

class PublicProfileController extends GetxController {
  final favoritesList = <FavoriteContent>[].obs;
  final isFavoritesLoading = false.obs;

  final ownShortsList = <ContentList>[].obs;
  final isShortsLoading = false.obs;

  final ownVideosList = <ContentList>[].obs;
  final isVideosLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
    fetchOwnShorts();
    fetchOwnVideos();
  }

  Future<void> fetchFavorites() async {
    isFavoritesLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) {
        isFavoritesLoading.value = false;
        return;
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}content/favorites/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        favoritesList.value = results.map((e) => FavoriteContent.fromJson(e)).toList();
      } else {
        print("Failed to fetch favorites: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  Future<void> fetchOwnShorts() async {
    isShortsLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) {
        isShortsLoading.value = false;
        return;
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}content/shorts/list/own/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        ownShortsList.value = results.map((e) => ContentList.fromJson(e)).toList();
      } else {
        print("Failed to fetch shorts: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching shorts: $e");
    } finally {
      isShortsLoading.value = false;
    }
  }

  Future<void> fetchOwnVideos() async {
    isVideosLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) {
        isVideosLoading.value = false;
        return;
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}content/vedio/list/own/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        ownVideosList.value = results.map((e) => ContentList.fromJson(e)).toList();
      } else {
        print("Failed to fetch videos: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching videos: $e");
    } finally {
      isVideosLoading.value = false;
    }
  }
}
