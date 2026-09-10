import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../models/history_menu_item.dart';

class EngagementHistoryController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final RxList<HistoryMenuItem> menuItems = <HistoryMenuItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _loadMenuData();
  }

  void _loadMenuData() {
    menuItems.assignAll([
      HistoryMenuItem(
        title: "Videos watched",
        subtitle: "Top 5 watched recently",
        icon: Icons.videocam,
        route: Routes.VIDEOS_WATCHED,
      ),
      HistoryMenuItem(
        title: "Likes and Dislikes",
        subtitle: "123 videos liked, 2 videos disliked",
        icon: Icons.thumb_up_alt_outlined,
        route: Routes.LIKES_DISLIKES,
      ),
      HistoryMenuItem(
        title: "Comments made",
        subtitle: "15 comments recently",
        icon: Icons.chat_bubble_outline,
        route: Routes.COMMENTS_MADE,
      ),
      HistoryMenuItem(
        title: "Favorite videos",
        subtitle: "15 videos recently",
        icon: Icons.favorite_border,
        route: Routes.FAVORITE_VIDEOS,
      ),
      HistoryMenuItem(
        title: "Video shared",
        subtitle: "30 videos shared recently",
        icon: Icons.share_outlined,
        route: Routes.VIDEO_SHARED,
      ),
    ]);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void onMenuItemTap(HistoryMenuItem item) {
    if (item.route.isNotEmpty) {
      Get.toNamed(item.route);
    }
  }
}
