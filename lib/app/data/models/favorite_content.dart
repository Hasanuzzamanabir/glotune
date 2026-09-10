class FavoriteContent {
  final int id;
  final int contentId;
  final int user;
  final String? createdAt;

  FavoriteContent({
    required this.id,
    required this.contentId,
    required this.user,
    this.createdAt,
  });

  factory FavoriteContent.fromJson(Map<String, dynamic> json) {
    return FavoriteContent(
      id: json['id'] as int,
      contentId: json['content'] as int,
      user: json['user'] as int,
      createdAt: json['created_at'] as String?,
    );
  }
}
