import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class CommentItem {
  final String id;
  final String videoId;
  final String videoTitle;
  final String videoThumbnailUrl;
  final String commentText;
  final String timestamp;

  CommentItem({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.videoThumbnailUrl,
    required this.commentText,
    required this.timestamp,
  });
}

class CommentsMadeController extends GetxController {
  final items = <CommentItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    items.assignAll([
      CommentItem(
        id: '1',
        videoId: 'v1',
        videoTitle: 'Exploring the Mountains',
        videoThumbnailUrl: 'https://picsum.photos/seed/com1/100/100',
        commentText: 'This is an amazing video! Really loved the scenery.',
        timestamp: '2 hours ago',
      ),
      CommentItem(
        id: '2',
        videoId: 'v2',
        videoTitle: 'My Daily VLOG',
        videoThumbnailUrl: 'https://picsum.photos/seed/com2/100/100',
        commentText: 'Great content as always, keep it up!',
        timestamp: '5 hours ago',
      ),
    ]);
  }

  void onItemTap(CommentItem item) {
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: {'videoId': item.videoId});
  }
}
