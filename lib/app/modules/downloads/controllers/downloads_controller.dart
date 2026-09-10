import 'package:get/get.dart';
import '../models/download_item_model.dart';

class DownloadsController extends GetxController {
  final downloads = <DownloadItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    downloads.assignAll([
      DownloadItem(
        id: '1',
        title: 'The Night of Sorrow (Part One)',
        timeAgo: '1 hour ago',
        thumbnailUrl: 'https://picsum.photos/seed/1/600/337',
        creatorProfileUrl: 'https://picsum.photos/seed/profile1/100/100',
      ),
      DownloadItem(
        id: '2',
        title: 'The Night of Sorrow (Part One)',
        timeAgo: '1 hour ago',
        thumbnailUrl: 'https://picsum.photos/seed/2/600/337',
        creatorProfileUrl: 'https://picsum.photos/seed/profile2/100/100',
      ),
      DownloadItem(
        id: '3',
        title: 'The Night of Sorrow (Part One)',
        timeAgo: '1 hour ago',
        thumbnailUrl: 'https://picsum.photos/seed/3/600/337',
        creatorProfileUrl: 'https://picsum.photos/seed/profile3/100/100',
      ),
      DownloadItem(
        id: '4',
        title: 'The Night of Sorrow (Part One)',
        timeAgo: '1 hour ago',
        thumbnailUrl: 'https://picsum.photos/seed/4/600/337',
        creatorProfileUrl: 'https://picsum.photos/seed/profile4/100/100',
      ),
    ]);
  }

  void onItemTap(DownloadItem item) {
    // Navigate to video player view
  }

  void onOptionsTap(DownloadItem item) {
    // Show bottom sheet options menu for deleting downloads
  }
}
