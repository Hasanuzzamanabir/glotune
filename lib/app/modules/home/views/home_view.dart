import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/data/models/shop_item.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/modules/subscriptions/views/subscriptions_view.dart';
import 'package:glotune/app/modules/profile/views/profile_view.dart';
import 'package:glotune/app/modules/studio/views/studio_view.dart';
import 'package:glotune/app/modules/community/views/community_view.dart';
import 'package:glotune/app/modules/content_creator_profile/views/content_creator_profile_view.dart';
import 'package:glotune/app/modules/content_creator_profile/controllers/content_creator_profile_controller.dart';
import 'package:glotune/app/modules/merchant_profile/views/merchant_profile_view.dart';
import 'package:glotune/app/modules/merchant_profile/controllers/merchant_profile_controller.dart';
import 'package:glotune/app/modules/talent_manager_profile/views/talent_manager_profile_view.dart';
import 'package:glotune/app/modules/talent_manager_profile/controllers/talent_manager_profile_controller.dart';
import 'package:glotune/app/modules/media_network_profile/views/media_network_profile_view.dart';
import 'package:glotune/app/modules/media_network_profile/controllers/media_network_profile_controller.dart';
import 'package:glotune/app/modules/viewer_profile/views/viewer_profile_view.dart';
import 'package:glotune/app/modules/viewer_profile/controllers/viewer_profile_controller.dart';
import '../controllers/home_controller.dart';
import 'widgets/video_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => Column(
          children: [
            // Custom Top Bar
            if (controller.currentIndex.value != 4 &&
                controller.currentIndex.value != 3)
              _buildTopBar(),

            // Main Content
            Expanded(
              child: () {
                if (controller.currentIndex.value == 0) {
                  if (controller.selectedTopTab.value == "Shop") {
                    return _buildShopContent();
                  }
                  if (controller.selectedTopTab.value == "Friends") {
                    return const CommunityView(isEmbedded: true);
                  }
                  return Column(
                    children: [
                      _buildCategoryBar(),
                      Expanded(child: _buildHomeFeed()),
                    ],
                  );
                } else if (controller.currentIndex.value == 1) {
                  return const SubscriptionsView();
                } else if (controller.currentIndex.value == 3) {
                  return const StudioView();
                } else if (controller.currentIndex.value == 4) {
                  if (controller.isProfileLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final type = controller.userType.value;
                  if (type == 'Creator') {
                    if (!Get.isRegistered<ContentCreatorProfileController>()) {
                      Get.put(ContentCreatorProfileController());
                    }
                    return const ContentCreatorProfileView();
                  } else if (type == 'Merchant') {
                    if (!Get.isRegistered<MerchantProfileController>()) {
                      Get.put(MerchantProfileController());
                    }
                    return const MerchantProfileView();
                  } else if (type == 'TalentManager' || type == 'Talent Manager') {
                    if (!Get.isRegistered<TalentManagerProfileController>()) {
                      Get.put(TalentManagerProfileController());
                    }
                    return const TalentManagerProfileView();
                  } else if (type == 'MediaNetwork' || type == 'Media Network') {
                    if (!Get.isRegistered<MediaNetworkProfileController>()) {
                      Get.put(MediaNetworkProfileController());
                    }
                    return const MediaNetworkProfileView();
                  } else if (type == 'Viewer') {
                    if (!Get.isRegistered<ViewerProfileController>()) {
                      Get.put(ViewerProfileController());
                    }
                    return const ViewerProfileView();
                  }
                  return const ProfileView();
                }
                return Center(
                  child: Text("Tab ${controller.currentIndex.value}"),
                );
              }(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: ScreenUtil().statusBarHeight + 10.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/logo_white.svg', height: 30.h),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.to(() => const ProfileView()),
                child: Obx(() => CircleAvatar(
                  radius: 16.r,
                  backgroundImage: controller.userAvatarUrl.value.isNotEmpty
                      ? NetworkImage(controller.userAvatarUrl.value)
                      : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                )),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: _showCastDialog,
                child: const Icon(Icons.cast, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () async {
                  await Get.toNamed(Routes.NOTIFICATIONS);
                  // Refresh count when returning from notifications view
                  controller.fetchUnreadNotificationCount();
                },
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 22,
                    ),
                    Obx(() {
                      if (controller.unreadNotificationCount.value > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              controller.unreadNotificationCount.value > 99
                                  ? '99+'
                                  : '${controller.unreadNotificationCount.value}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.SETTINGS),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.SEARCH),
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // White pill with tabs (full-width, no scrolling; tabs evenly distributed)
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Row(
                children: controller.topTabs.map((tab) {
                  bool isSelected = controller.selectedTopTab.value == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectTopTab(tab),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 3.h,
                          horizontal: 2.w,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 6.h,
                          ),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(28.r),
                                )
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (tab == 'Videos') ...[
                                Icon(
                                  Icons.play_arrow,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 3.w),
                              ] else if (tab == 'Live') ...[
                                Icon(
                                  Icons.wifi_tethering,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 3.w),
                              ] else if (tab == 'Friends') ...[
                                Icon(
                                  Icons.people,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 3.w),
                              ] else ...[
                                Icon(
                                  Icons.shop,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 3.w),
                              ],
                              Flexible(
                                child: Text(
                                  tab,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(
          () => Row(
            children: controller.categories.map((cat) {
              bool isSelected = controller.selectedCategory.value == cat;
              return GestureDetector(
                onTap: () => controller.selectCategory(cat),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeFeed() {
    return Obx(() {
      if (controller.selectedTopTab.value == "Live") {
        final rooms = controller.liveRooms;
        if (rooms.isEmpty) {
          return const Center(
            child: Text(
              "No live rooms found.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshHome,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              
              String avatarUrl = "";
              if (room.host.profilePicture != null && room.host.profilePicture!.isNotEmpty) {
                avatarUrl = room.host.profilePicture!;
              }

              return GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.LIVE_PLAYER, arguments: room.roomId);
                },
                child: VideoCard(
                  title: room.title,
                  creator: room.host.username ?? "Unknown Host",
                  views: "${room.memberCount} watching",
                  time: room.startedAt != null ? "Started recently" : "Unknown time",
                  duration: "LIVE",
                  thumbnailUrl: avatarUrl,
                  creatorAvatarUrl: avatarUrl,
                  onMorePressed: () => _showVideoOptions(),
                  onAvatarTap: () {
                    Get.toNamed(Routes.OTHER_PROFILE, arguments: room.host.id);
                  },
                ),
              );
            },
          ),
        );
      }

      final videos = controller.filteredVideos;
      if (videos.isEmpty) {
        return const Center(
          child: Text(
            "No videos found for this category.",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshHome,
        color: AppColors.primary,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(), // Ensures it can be pulled even if not overflowing
          itemCount: videos.length,
          itemBuilder: (context, index) {
          final video = videos[index];
          
          // Map properties
          String thumbUrl = "";
          if (video.thumbnail != null && video.thumbnail!.isNotEmpty) {
            thumbUrl = video.thumbnail!;
          } else if (video.video != null && video.video!.isNotEmpty) {
            // No thumbnail provided
            thumbUrl = "";
          }

          String avatarUrl = "";
          if (video.authorProfile != null && video.authorProfile!.isNotEmpty) {
            avatarUrl = video.authorProfile!;
          }

          return _buildHomeVideoCard(
            title: video.title,
            creator: video.authorName,
            views: "${video.viewsCount} views",
            time: video.createdAtAgoTime ?? "",
            duration: video.contentType == "shorts" ? "Short" : (video.categoryName?.contains("Live") == true ? "LIVE" : "10:00"),
            thumbnailUrl: thumbUrl,
            creatorAvatarUrl: avatarUrl,
            videoData: video,
            onAvatarTap: () {
              if (video.author != null) {
                Get.toNamed(Routes.OTHER_PROFILE, arguments: video.author);
              }
            },
          );
        },
      ));
    });
  }

  Widget _buildHomeVideoCard({
    required String title,
    required String creator,
    required String views,
    required String time,
    required String duration,
    required String thumbnailUrl,
    required String creatorAvatarUrl,
    required dynamic videoData, // pass the ContentList object down if needed
    VoidCallback? onAvatarTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (videoData.contentType == 'shorts') {
          // You might need to handle clicking a short differently if it shouldn't open standard VideoPlayer
          Get.toNamed(Routes.VIDEO_PLAYER, arguments: videoData);
        } else {
          Get.toNamed(Routes.VIDEO_PLAYER, arguments: videoData);
        }
      },
      child: VideoCard(
        title: title,
        creator: creator,
        views: views,
        time: time,
        duration: duration,
        thumbnailUrl: thumbnailUrl,
        creatorAvatarUrl: creatorAvatarUrl,
        onMorePressed: () => _showVideoOptions(),
        onAvatarTap: onAvatarTap,
      ),
    );
  }

  void _showVideoOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              Icons.monetization_on_outlined, 
              "Donate",
              onTap: () {
                Get.back();
                Get.toNamed(Routes.MAKE_DONATION);
              },
            ),
            _buildOptionItem(Icons.favorite_border, "Subscribe"),
            _buildOptionItem(Icons.bookmark_border, "Save"),
            _buildOptionItem(Icons.download_for_offline_outlined, "Download"),
            _buildOptionItem(Icons.share_outlined, "Share"),
            _buildOptionItem(Icons.info_outline, "Report", isDestructive: true),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOptionItem(
    IconData icon,
    String label, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
        size: 24.sp,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      onTap: onTap ?? () => Get.back(),
    );
  }

  void _showCastDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: 20.h),
            Row(
              children: [
                const Icon(Icons.cast, color: Colors.black87),
                SizedBox(width: 12.w),
                Text("Cast to a device", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            SizedBox(height: 30.h),
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16.h),
            Text("Searching for devices on your network...", style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined),
            label: "Subscription",
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(top: 8.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add, size: 30),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.video_settings_outlined),
            label: "Studio",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildShopContent() {
    return Column(
      children: [
        _buildShopCategoryBar(),
        _buildShopSearchBar(),
        Expanded(child: _buildShopGrid()),
      ],
    );
  }

  Widget _buildShopCategoryBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Obx(() {
        if (controller.isShopCategoriesLoading.value) {
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
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2.h,
                      ),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey,
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
                  color: hasFilters ? Colors.orange : AppColors.primary,
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
      if (controller.isShopItemsLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      final items = controller.filteredShopItems;
      if (items.isEmpty) {
        return const Center(child: Text("No items found"));
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
                  child: const CircularProgressIndicator(color: AppColors.primary),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildShopItemCard(ShopItem item, double imageHeight) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: item),
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
                    Icon(Icons.image_not_supported, color: Colors.grey),
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
    ),);
  }

  void _showFilterBottomSheet(BuildContext context) {
    double tempMinPrice = controller.minPriceFilter.value ?? 0.0;
    double tempMaxPrice = controller.maxPriceFilter.value ?? 500.0;
    if (tempMaxPrice < tempMinPrice) tempMaxPrice = tempMinPrice + 100;

    String tempSortBy = controller.sortBy.value;
    bool tempOnSaleOnly = controller.onSaleOnly.value;
    
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
                      child: Text(
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
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: tempSortBy == sortOption
                                ? AppColors.primary
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
                  activeColor: AppColors.primary,
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
                      activeThumbColor: AppColors.primary,
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
                      backgroundColor: AppColors.primary,
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
