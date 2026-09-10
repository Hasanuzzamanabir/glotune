import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/content_list.dart';
import 'package:glotune/app/data/models/user_profile.dart';

class OtherProfileController extends GetxController {
  late final int userId;

  final profileData = Rxn<UserProfile>();
  final isProfileLoading = true.obs;
  final errorMessage = RxnString();

  final isFollowing = false.obs;
  final isFollowLoading = false.obs;

  final isSubscribed = false.obs;
  final isSubscribeLoading = false.obs;

  final userShortsList = <ContentList>[].obs;
  final userVideosList = <ContentList>[].obs;
  final isContentLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments as int;
    fetchProfileData();
    fetchUserContent();
  }

  Future<void> fetchProfileData() async {
    isProfileLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}others/users/profile/$userId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        profileData.value = UserProfile.fromJson(data);
        // If backend added is_following to the profile response, use it:
        final isFoll = data['is_following'] ?? data['is_follow'] ?? data['isFollow'];
        if (isFoll != null) {
          final isFollStr = isFoll.toString().toLowerCase();
          isFollowing.value = isFoll == true || isFollStr == 'true' || isFollStr == '1';
        }
        final isSub = data['is_subscribed'] ?? data['is_subscribe'] ?? data['isSubscribe'];
        if (isSub != null) {
          final isSubStr = isSub.toString().toLowerCase();
          isSubscribed.value = isSub == true || isSubStr == 'true' || isSubStr == '1';
        }
      } else {
        errorMessage.value =
            "Failed to fetch profile: ${response.statusCode} - ${response.body}";
        print("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      errorMessage.value = "Error fetching profile: $e";
      print("Error fetching profile: $e");
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> fetchUserContent() async {
    isContentLoading.value = true;
    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}content/list/public/?author=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        final allContent = results.map((e) => ContentList.fromJson(e)).toList();

        userShortsList.value = allContent
            .where((item) => item.contentType == 'shorts')
            .toList();
        userVideosList.value = allContent
            .where((item) => item.contentType == 'video')
            .toList();
      } else {
        print("Failed to fetch user content: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user content: $e");
    } finally {
      isContentLoading.value = false;
    }
  }

  Future<void> toggleFollow() async {
    if (isFollowLoading.value) return;

    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) {
      Get.snackbar('Error', 'Please login to follow users');
      return;
    }

    isFollowLoading.value = true;
    try {
      if (isFollowing.value) {
        // Unfollow
        final response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}unfollow/$userId/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          isFollowing.value = false;
          if (profileData.value != null) {
            profileData.value = profileData.value!.copyWith(
              followerCount: (profileData.value!.followerCount > 0)
                  ? profileData.value!.followerCount - 1
                  : 0,
            );
          }
        } else {
          Get.snackbar('Error', 'Failed to unfollow: ${response.statusCode}');
        }
      } else {
        // Follow
        final response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}follow/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'user_id': userId, 'bell_notification': false}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          isFollowing.value = true;
          if (profileData.value != null) {
            profileData.value = profileData.value!.copyWith(
              followerCount: profileData.value!.followerCount + 1,
            );
          }
        } else {
          try {
            final errorBody = jsonDecode(response.body);
            if (errorBody is Map<String, dynamic> &&
                errorBody.containsKey('error')) {
              Get.snackbar('Error', errorBody['error'].toString());
            } else {
              Get.snackbar('Error', 'Failed to follow: ${response.statusCode}');
            }
          } catch (_) {
            Get.snackbar('Error', 'Failed to follow: ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
      print('Follow error: $e');
    } finally {
      isFollowLoading.value = false;
    }
  }

  Future<void> toggleSubscribe() async {
    if (isSubscribeLoading.value) return;

    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) {
      Get.snackbar('Error', 'Please login to subscribe to users');
      return;
    }

    isSubscribeLoading.value = true;
    try {
      if (isSubscribed.value) {
        // Unsubscribe
        final response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}chanale/unsubscribe/$userId/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          isSubscribed.value = false;
          if (profileData.value != null) {
            profileData.value = profileData.value!.copyWith(
              subscriberCount: (profileData.value!.subscriberCount > 0)
                  ? profileData.value!.subscriberCount - 1
                  : 0,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Failed to unsubscribe: ${response.statusCode}',
          );
        }
      } else {
        // Subscribe
        final response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}chanale/subscribe/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'user_id': userId, 'bell_notification': false}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          isSubscribed.value = true;
          if (profileData.value != null) {
            profileData.value = profileData.value!.copyWith(
              subscriberCount: profileData.value!.subscriberCount + 1,
            );
          }
        } else {
          try {
            final errorBody = jsonDecode(response.body);
            if (errorBody is Map<String, dynamic> &&
                errorBody.containsKey('error')) {
              Get.snackbar('Error', errorBody['error'].toString());
            } else {
              Get.snackbar(
                'Error',
                'Failed to subscribe: ${response.statusCode}',
              );
            }
          } catch (_) {
            Get.snackbar(
              'Error',
              'Failed to subscribe: ${response.statusCode}',
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
      print('Subscribe error: $e');
    } finally {
      isSubscribeLoading.value = false;
    }
  }

  Future<void> blockUser() async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) {
      Get.snackbar('Error', 'Please login to block users');
      return;
    }

    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}user-block/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'blocked_user': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // close bottom sheet
        Get.snackbar('Success', 'User blocked successfully');
        // Optionally navigate away since user is blocked
        Get.back(); // go back from profile
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic> &&
              errorBody.containsKey('error')) {
            Get.snackbar('Error', errorBody['error'].toString());
          } else {
            Get.snackbar(
              'Error',
              'Failed to block user: ${response.statusCode}',
            );
          }
        } catch (_) {
          Get.snackbar('Error', 'Failed to block user: ${response.statusCode}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while blocking');
      print('Block error: $e');
    }
  }

  void shareProfile() {
    if (profileData.value == null) return;
    final name = profileData.value!.fullName?.isNotEmpty == true
        ? profileData.value!.fullName
        : "this user";
    final profileUrl =
        "https://glotune.com/profile/$userId"; // Deep link or web fallback
    Share.share('Check out $name on Glotune!\n$profileUrl');
  }
}
