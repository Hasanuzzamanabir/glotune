class ContentComment {
  final int id;
  final int? contentId;
  final int commenter;
  final String commenterName;
  final String commenterUsername;
  final String? commenterProfile;
  final String comment;
  final String? createdAt;
  final String? createdAtTimeAgo;
  final String? commentLikesCount;
  final String? commentDislikesCount;
  final List<ContentCommentReply>? replies;

  ContentComment({
    required this.id,
    this.contentId,
    required this.commenter,
    required this.commenterName,
    required this.commenterUsername,
    this.commenterProfile,
    required this.comment,
    this.createdAt,
    this.createdAtTimeAgo,
    this.commentLikesCount,
    this.commentDislikesCount,
    this.replies,
  });

  factory ContentComment.fromJson(Map<String, dynamic> json) {
    return ContentComment(
      id: json['id'] as int,
      contentId: json['content_id'] as int?,
      commenter: json['commenter'] as int,
      commenterName: json['commenter_name'] as String? ?? '',
      commenterUsername: json['commenter_username'] as String? ?? '',
      commenterProfile: json['commenter_profile'] as String?,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      createdAtTimeAgo: json['created_at_time_ago'] as String?,
      commentLikesCount: json['comment_likes_count']?.toString(),
      commentDislikesCount: json['comment_dislikes_count']?.toString(),
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => ContentCommentReply.fromJson(r)).toList()
          : null,
    );
  }
}

class ContentCommentReply {
  final int id;
  final int? commentId;
  final int commenter;
  final String commenterName;
  final String commenterUsername;
  final String? commenterProfile;
  final String comment;
  final String? createdAt;
  final String? createdAtTimeAgo;
  final String? commentLikesCount;
  final String? commentDislikesCount;
  final List<ContentCommentReply>? replies;

  ContentCommentReply({
    required this.id,
    this.commentId,
    required this.commenter,
    required this.commenterName,
    required this.commenterUsername,
    this.commenterProfile,
    required this.comment,
    this.createdAt,
    this.createdAtTimeAgo,
    this.commentLikesCount,
    this.commentDislikesCount,
    this.replies,
  });

  factory ContentCommentReply.fromJson(Map<String, dynamic> json) {
    return ContentCommentReply(
      id: json['id'] as int,
      commentId: json['comment_id'] as int?,
      commenter: json['commenter'] as int,
      commenterName: json['commenter_name'] as String? ?? '',
      commenterUsername: json['commenter_username'] as String? ?? '',
      commenterProfile: json['commenter_profile'] as String?,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      createdAtTimeAgo: json['created_at_time_ago'] as String?,
      commentLikesCount: json['comment_likes_count']?.toString(),
      commentDislikesCount: json['comment_dislikes_count']?.toString(),
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => ContentCommentReply.fromJson(r)).toList()
          : null,
    );
  }
}
