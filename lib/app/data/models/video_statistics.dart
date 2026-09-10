class VideoStatistics {
  final int totalViews;
  final String totalWatchTime;
  final String averageEngagement;
  final String totalEarnings;
  final int totalShared;
  final int totalLikes;
  final List<VideoStatItem> performanceTable;

  VideoStatistics({
    required this.totalViews,
    required this.totalWatchTime,
    required this.averageEngagement,
    required this.totalEarnings,
    required this.totalShared,
    required this.totalLikes,
    required this.performanceTable,
  });

  factory VideoStatistics.fromJson(Map<String, dynamic> json) {
    var list = json['most_views_video_performance_table'] as List? ?? [];
    List<VideoStatItem> performanceList =
        list.map((i) => VideoStatItem.fromJson(i)).toList();

    return VideoStatistics(
      totalViews: json['total_views'] ?? 0,
      totalWatchTime: json['total_watch_time']?.toString() ?? '0.0',
      averageEngagement: json['average_engagement']?.toString() ?? '0.0',
      totalEarnings: json['total_earnings']?.toString() ?? '0.00',
      totalShared: json['total_shared'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      performanceTable: performanceList,
    );
  }
}

class VideoStatItem {
  final int contentId;
  final String title;
  final int views;
  final int likes;
  final int shares;

  VideoStatItem({
    required this.contentId,
    required this.title,
    required this.views,
    required this.likes,
    required this.shares,
  });

  factory VideoStatItem.fromJson(Map<String, dynamic> json) {
    return VideoStatItem(
      contentId: json['content_id'] ?? 0,
      title: json['title'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }
}
