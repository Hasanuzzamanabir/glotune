import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/favorite_content.dart';
import 'package:glotune/app/data/models/content_list.dart';

class UserProfile {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String type;
  final String route;
  final String? country;
  final String? city;
  final int followersCount;
  final int followingCount;
  final int subscribersCount;
  final int videosCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.type,
    required this.route,
    this.country,
    this.city,
    this.followersCount = 0,
    this.followingCount = 0,
    this.subscribersCount = 0,
    this.videosCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String?;
    final username = json['username'] as String?;
    final email = json['email'] as String? ?? '';
    
    final resolvedName = (fullName != null && fullName.isNotEmpty) 
        ? fullName 
        : (username != null && username.isNotEmpty ? username : 'User');
        
    final handleFallback = email.isNotEmpty ? '@${email.split('@')[0]}' : '@user';

    return UserProfile(
      id: json['id']?.toString() ?? 'viewer',
      name: resolvedName,
      handle: username != null ? '@$username' : handleFallback,
      avatarUrl: json['profile_picture_url'] as String? ?? json['profile_picture'] as String? ?? "assets/images/user_avatar.png",
      type: json['user_type'] as String? ?? "Viewer",
      route: Routes.VIEWER_PROFILE,
      country: json['country_name'] as String? ?? json['country'] as String?,
      city: json['city_name'] as String? ?? json['city'] as String?,
      followersCount: json['follower_count'] as int? ?? json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      subscribersCount: json['suscriber_count'] as int? ?? json['subscriber_count'] as int? ?? 0,
      videosCount: json['videos_count'] as int? ?? json['videos'] as int? ?? 0,
    );
  }
}

class ProfileController extends GetxController {
  final selectedMetric = "Earnings".obs; // Earnings vs Purchases
  
  final allProfiles = <UserProfile>[
    UserProfile(
      id: 'viewer',
      name: "Viewer Profile",
      handle: "@viewer",
      avatarUrl: "assets/images/user_avatar.png",
      type: "Viewer",
      route: Routes.VIEWER_PROFILE,
    ),
    UserProfile(
      id: 'talent',
      name: "Talent Manager Profile",
      handle: "@talent_mgr",
      avatarUrl: "https://picsum.photos/200/200?random=21",
      type: "Manager",
      route: Routes.TALENT_MANAGER_PROFILE,
    ),
    UserProfile(
      id: 'merchant',
      name: "Merchant Profile",
      handle: "@merchant",
      avatarUrl: "https://picsum.photos/200/200?random=22",
      type: "Merchant",
      route: Routes.MERCHANT_PROFILE,
    ),
    UserProfile(
      id: 'creator',
      name: "Content Creator Profile",
      handle: "@creator",
      avatarUrl: "https://picsum.photos/200/200?random=23",
      type: "Creator",
      route: Routes.CONTENT_CREATOR_PROFILE,
    ),
    UserProfile(
      id: 'media_network',
      name: "Media Network Profile",
      handle: "@camwils34",
      avatarUrl: "https://picsum.photos/200/200?random=41",
      type: "Media Network",
      route: Routes.MEDIA_NETWORK_PROFILE,
    ),
  ].obs;

  late final Rx<UserProfile> activeProfile;
  final favoritesList = <FavoriteContent>[].obs;
  final isFavoritesLoading = false.obs;

  final ownShortsList = <ContentList>[].obs;
  final isShortsLoading = false.obs;

  final ownVideosList = <ContentList>[].obs;
  final isVideosLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    activeProfile = allProfiles.first.obs;
    fetchActualProfile();
    fetchFavorites();
    fetchOwnShorts();
    fetchOwnVideos();
  }

  Future<void> fetchActualProfile() async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null) return;

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}auth/profile/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        activeProfile.value = UserProfile.fromJson(data);
      } else {
        print("Failed to fetch actual profile: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching actual profile: $e");
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
        print("Failed to fetch own shorts: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching own shorts: $e");
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
        print("Failed to fetch own videos: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching own videos: $e");
    } finally {
      isVideosLoading.value = false;
    }
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

  void setMetric(String metric) => selectedMetric.value = metric;

  void switchProfile(UserProfile profile) {
    activeProfile.value = profile;
  }
}
