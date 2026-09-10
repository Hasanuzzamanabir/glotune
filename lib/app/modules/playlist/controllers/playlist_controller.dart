import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../models/playlist_item_model.dart';

class PlaylistController extends GetxController {
  final RxList<PlaylistItem> playlists = <PlaylistItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlaylists();
  }

  void _loadPlaylists() {
    playlists.assignAll([
      PlaylistItem(
        id: '1',
        title: "My Favorites",
        count: "45 videos",
        subtitle: "Updated yesterday",
        coverUrl: 'https://picsum.photos/seed/fav/400/400',
      ),
      PlaylistItem(
        id: '2',
        title: "Watch Later",
        count: "12 videos",
        subtitle: "Private",
        coverUrl: 'https://picsum.photos/seed/watch/400/400',
      ),
      PlaylistItem(
        id: '3',
        title: "Learning Dev",
        count: "88 videos",
        subtitle: "Public",
        coverUrl: 'https://picsum.photos/seed/dev/400/400',
      ),
      PlaylistItem(
        id: '4',
        title: "Lo-Fi Beats",
        count: "210 videos",
        subtitle: "Curated",
        coverUrl: 'https://picsum.photos/seed/lofi/400/400',
      ),
    ]);
  }

  void onPlaylistTap(PlaylistItem item) {
    Get.toNamed(Routes.PLAYLIST_DETAILS, arguments: {'playlistId': item.id});
  }
}
