import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class FavoriteItem {
  final String id;
  final String title;
  final String creatorName;
  final String coverUrl;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.creatorName,
    required this.coverUrl,
  });
}

class FavoriteVideosController extends GetxController {
  final items = <FavoriteItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    items.assignAll([
      FavoriteItem(
        id: '1',
        title: 'Learn Flutter in 2 hours',
        creatorName: 'Tech Academy',
        coverUrl: 'https://picsum.photos/seed/favv1/400/400',
      ),
      FavoriteItem(
        id: '2',
        title: 'Relaxing Lo-Fi',
        creatorName: 'Chill Beats',
        coverUrl: 'https://picsum.photos/seed/favv2/400/400',
      ),
      FavoriteItem(
        id: '3',
        title: 'Epic Mountain Biking',
        creatorName: 'Extreme Sports',
        coverUrl: 'https://picsum.photos/seed/favv3/400/400',
      ),
    ]);
  }

  void onItemTap(FavoriteItem item) {
    Get.toNamed(Routes.VIDEO_PLAYER, arguments: {'videoId': item.id});
  }
}
