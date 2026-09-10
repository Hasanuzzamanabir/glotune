class ContentList {
  final int id;
  final int author;
  final String authorName;
  final int? category;
  final String? categoryName;
  final String? contentType;
  final String? status;
  final String title;
  final String description;
  final String? thumbnail;
  final String? video;
  final String? authorProfile;
  final int viewsCount;
  final int favoriteCount;
  final String? likeCount;
  final String? dislikeCount;
  final int shareCount;
  final String? createdAt;
  final String? createdAtAgoTime;
  final String? commentCount;

  ContentList({
    required this.id,
    required this.author,
    required this.authorName,
    this.category,
    this.categoryName,
    this.contentType,
    this.status,
    required this.title,
    required this.description,
    this.thumbnail,
    this.video,
    this.authorProfile,
    required this.viewsCount,
    required this.favoriteCount,
    this.likeCount,
    this.dislikeCount,
    required this.shareCount,
    this.createdAt,
    this.createdAtAgoTime,
    this.commentCount,
  });

  factory ContentList.fromJson(Map<String, dynamic> json) {
    return ContentList(
      id: json['id'] as int,
      author: json['author'] as int,
      authorName: json['author_name'] as String? ?? '',
      category: json['category'] as int?,
      categoryName: json['category_name'] as String?,
      contentType: json['content_type'] as String?,
      status: json['status'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      video: json['video'] as String?,
      authorProfile: json['author_profile'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      likeCount: json['like_count']?.toString(),
      dislikeCount: json['dislike_count']?.toString(),
      shareCount: json['share_count'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      createdAtAgoTime: json['created_at_ago_time'] as String?,
      commentCount: json['comment_count']?.toString(),
    );
  }
}
