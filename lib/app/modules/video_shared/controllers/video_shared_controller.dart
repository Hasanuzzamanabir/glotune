import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SharedItem {
  final String id;
  final String videoId;
  final String thumbnailUrl;
  final String videoTitle;
  final String platform;
  final String timestamp;

  SharedItem({
    required this.id,
    required this.videoId,
    required this.thumbnailUrl,
    required this.videoTitle,
    required this.platform,
    required this.timestamp,
  });
}

class VideoSharedController extends GetxController {
  final items = <SharedItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    items.assignAll([
      SharedItem(
        id: '1',
        videoId: 'v1',
        thumbnailUrl: 'https://picsum.photos/seed/share1/100/100',
        videoTitle: 'Mastering Flutter UI Design',
        platform: 'WhatsApp',
        timestamp: '2 hours ago',
      ),
      SharedItem(
        id: '2',
        videoId: 'v2',
        thumbnailUrl: 'https://picsum.photos/seed/share2/100/100',
        videoTitle: 'Exploring the Mountains',
        platform: '@user_123',
        timestamp: 'Yesterday',
      ),
    ]);
  }

  void onItemTap(SharedItem item) {
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: {'videoId': item.videoId});
  }

  void onOutboundTap(SharedItem item) {
    // Implement external link logic if needed, currently navigates to video
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: {'videoId': item.videoId});
  }
}
