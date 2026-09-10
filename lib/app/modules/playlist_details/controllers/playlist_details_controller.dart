import 'package:get/get.dart';

class PlaylistDetailsInfo {
  final String title;
  final String creator;
  final String coverUrl;
  final String visibility;
  final int videoCount;
  final String updateTime;

  PlaylistDetailsInfo({
    required this.title,
    required this.creator,
    required this.coverUrl,
    required this.visibility,
    required this.videoCount,
    required this.updateTime,
  });
}

class PlaylistVideoItem {
  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String duration;
  final String views;
  final String timeAgo;

  PlaylistVideoItem({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.timeAgo,
  });
}

class PlaylistDetailsController extends GetxController {
  late final Rx<PlaylistDetailsInfo> playlistInfo;
  final RxList<PlaylistVideoItem> videos = <PlaylistVideoItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Check if arguments were passed
    final String playlistId = Get.arguments?['playlistId'] ?? '1';

    // Mock data for playlist header
    playlistInfo = PlaylistDetailsInfo(
      title: "My Favorites",
      creator: "GloTune User",
      coverUrl: "https://picsum.photos/seed/fav/400/400",
      visibility: "Public",
      videoCount: 15,
      updateTime: "Updated today",
    ).obs;

    // Mock data for playlist videos
    videos.assignAll([
      PlaylistVideoItem(
        id: "v1",
        title: "Flutter UI Tutorial - Build a Music Player App",
        channelName: "Flutter Mastery",
        thumbnailUrl: "https://picsum.photos/seed/vid1/400/225",
        duration: "14:20",
        views: "1.2M views",
        timeAgo: "2 years ago",
      ),
      PlaylistVideoItem(
        id: "v2",
        title: "Top 10 Relaxing Lofi Beats 2026",
        channelName: "Chill Vibes",
        thumbnailUrl: "https://picsum.photos/seed/vid2/400/225",
        duration: "45:00",
        views: "340K views",
        timeAgo: "3 months ago",
      ),
      PlaylistVideoItem(
        id: "v3",
        title: "Advanced GetX State Management",
        channelName: "Code With Me",
        thumbnailUrl: "https://picsum.photos/seed/vid3/400/225",
        duration: "22:15",
        views: "89K views",
        timeAgo: "1 year ago",
      ),
      PlaylistVideoItem(
        id: "v4",
        title: "Behind the Scenes: My Studio Setup",
        channelName: "Tech Creator",
        thumbnailUrl: "https://picsum.photos/seed/vid4/400/225",
        duration: "8:45",
        views: "210K views",
        timeAgo: "5 days ago",
      ),
      PlaylistVideoItem(
        id: "v5",
        title: "100 Days of Code - Day 1",
        channelName: "Dev Journey",
        thumbnailUrl: "https://picsum.photos/seed/vid5/400/225",
        duration: "5:30",
        views: "15K views",
        timeAgo: "1 week ago",
      ),
    ]);
  }
}
