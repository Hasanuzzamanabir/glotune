import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class VideoItem {
  final String id;
  final String title;
  final String timestamp;
  final String duration;
  final String thumbnailUrl;
  final int likes;
  final int comments;
  final int views;
  final int shares;

  VideoItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.duration,
    required this.thumbnailUrl,
    required this.likes,
    required this.comments,
    required this.views,
    required this.shares,
  });
}

class VideosWatchedController extends GetxController {
  final videos = <VideoItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    videos.assignAll([
      VideoItem(
        id: '1',
        title: 'Mastering Flutter UI Design',
        timestamp: '3 days ago',
        duration: '10:54',
        thumbnailUrl: 'https://picsum.photos/seed/vid1/400/225',
        likes: 1200,
        comments: 340,
        views: 15000,
        shares: 45,
      ),
      VideoItem(
        id: '2',
        title: 'Advanced State Management with GetX',
        timestamp: '5 days ago',
        duration: '25:12',
        thumbnailUrl: 'https://picsum.photos/seed/vid2/400/225',
        likes: 850,
        comments: 120,
        views: 8900,
        shares: 30,
      ),
    ]);
  }

  void onVideoTap(VideoItem item) {
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: {'videoId': item.id});
  }
}
