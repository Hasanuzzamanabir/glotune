import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class VideoActionItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final bool isLiked; // true for liked, false for disliked
  final String dateGroup; // e.g. "Today", "Yesterday"

  VideoActionItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.isLiked,
    required this.dateGroup,
  });
}

class LikesDislikesController extends GetxController {
  final items = <VideoActionItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    items.assignAll([
      VideoActionItem(
        id: '1',
        title: 'Exploring the Mountains',
        thumbnailUrl: 'https://picsum.photos/seed/like1/100/100',
        isLiked: true,
        dateGroup: 'Today',
      ),
      VideoActionItem(
        id: '2',
        title: '10 Tips for Better Code',
        thumbnailUrl: 'https://picsum.photos/seed/like2/100/100',
        isLiked: false,
        dateGroup: 'Today',
      ),
      VideoActionItem(
        id: '3',
        title: 'My Daily VLOG',
        thumbnailUrl: 'https://picsum.photos/seed/like3/100/100',
        isLiked: true,
        dateGroup: 'Yesterday',
      ),
    ]);
  }

  void onItemTap(VideoActionItem item) {
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: {'videoId': item.id});
  }
}
