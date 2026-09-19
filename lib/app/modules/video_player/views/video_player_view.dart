import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/modules/home/views/widgets/video_card.dart';
import 'package:glotune/app/data/models/content_comment.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/video_player_controller.dart';

class VideoPlayerView extends GetView<VideoPlayerController> {
  const VideoPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          controller.videoData?.title ?? 'Unknown Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Area
            _buildVideoPlayer(),

            // Video Metadata
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.videoData?.title ?? 'Unknown Video',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${controller.videoData?.viewsCount ?? 0} views • ${controller.videoData?.createdAtAgoTime ?? ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Channel Branding
                  _buildChannelBranding(),

                  SizedBox(height: 16.h),

                  // Action Toolbar
                  _buildActionToolbar(),

                  SizedBox(height: 24.h),

                  // Comment Preview
                  _buildCommentPreview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Obx(() {
      if (!controller.isVideoInitialized.value ||
          controller.chewieController == null) {
        return Container(
          height: 220.h,
          width: double.infinity,
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
      return Container(
        height: 220.h,
        width: double.infinity,
        color: Colors.black,
        child: Chewie(controller: controller.chewieController!),
      );
    });
  }

  Widget _buildChannelBranding() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (controller.videoData?.author != null) {
              Get.toNamed(
                Routes.OTHER_PROFILE,
                arguments: controller.videoData!.author,
              );
            }
          },
          child: CircleAvatar(
            radius: 18.r,
            backgroundImage: controller.videoData?.authorProfile != null
                ? CachedNetworkImageProvider(
                        controller.videoData!.authorProfile!,
                      )
                      as ImageProvider
                : const AssetImage('assets/images/user_avatar.png'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.videoData?.authorName ?? 'Unknown Creator',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'Creator',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => ElevatedButton(
            onPressed: controller.toggleSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isSubscribed.value
                  ? AppColors.border
                  : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
            ),
            child: controller.isSubscribeLoading.value
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    controller.isSubscribed.value ? 'Subscribed' : 'Subscribe',
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Obx(
            () => _buildActionButton(
              controller.isLiked.value
                  ? Icons.thumb_up
                  : Icons.thumb_up_outlined,
              '${controller.likeCount.value}',
              isLiked: controller.isLiked.value,
              onTap: controller.toggleLike,
            ),
          ),
          Obx(
            () => _buildActionButton(
              controller.isDisliked.value
                  ? Icons.thumb_down
                  : Icons.thumb_down_outlined,
              '${controller.dislikeCount.value}',
              isLiked: controller.isDisliked.value,
              onTap: controller.toggleDislike,
            ),
          ),
          Obx(
            () => _buildActionButton(
              Icons.share_outlined,
              '${controller.shareCount.value}',
              onTap: controller.shareContent,
            ),
          ),
          _buildActionButton(Icons.download_outlined, 'Download'),
          _buildActionButton(Icons.card_giftcard, 'Gift'),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    bool isLiked = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.w,
              color: isLiked ? AppColors.primary : AppColors.textPrimary,
            ),
            if (label.isNotEmpty) ...[
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isLiked ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreview() {
    return GestureDetector(
      onTap: _showComments,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(() {
                  final length = controller.comments.length;
                  return Text(
                    controller.videoData?.commentCount ?? '$length',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  );
                }),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(() {
              if (controller.comments.isEmpty) {
                return Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                );
              }
              final topComment = controller.comments.first;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 12.r,
                    backgroundImage: topComment.commenterProfile != null
                        ? CachedNetworkImageProvider(
                                topComment.commenterProfile!,
                              )
                              as ImageProvider
                        : const AssetImage('assets/images/user_avatar.png'),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      topComment.comment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showComments() {
    Get.bottomSheet(
      _CommentsOverlay(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _CommentsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _CommentsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Text(
                        'Top',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Newest',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Comments List
              Expanded(
                child: Obx(() {
                  if (controller.comments.isEmpty) {
                    return Center(
                      child: Text(
                        'No comments yet. Be the first to comment!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(controller.comments[index]);
                    },
                  );
                }),
              ),

              // Input Field
              _buildCommentInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(ContentComment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSingleComment(comment),
        if (comment.replies != null && comment.replies!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 48.w),
            child: Column(
              children: comment.replies!
                  .map((reply) => _buildReplyItem(reply))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSingleComment(ContentComment comment) {
    final currentUserId = Get.find<AuthService>().currentUserId.value;
    final isMyComment =
        currentUserId != null && comment.commenter == currentUserId;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: comment.commenterProfile != null
                ? CachedNetworkImageProvider(comment.commenterProfile!)
                      as ImageProvider
                : const AssetImage('assets/images/user_avatar.png'),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${comment.commenterUsername}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      comment.createdAtTimeAgo ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(comment.comment, style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 12.h),
                Obx(() {
                  final isLiked =
                      controller.commentIsLikedMap[comment.id]?.value ?? false;
                  final isDisliked =
                      controller.commentIsDislikedMap[comment.id]?.value ??
                      false;
                  final likeCount =
                      controller.commentLikeCountMap[comment.id]?.value ??
                      (int.tryParse(comment.commentLikesCount ?? '0') ?? 0);
                  final dislikeCount =
                      controller.commentDislikeCountMap[comment.id]?.value ??
                      (int.tryParse(comment.commentDislikesCount ?? '0') ?? 0);

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.toggleCommentLike(
                          comment.id,
                          comment.commentLikesCount,
                          comment.commentDislikesCount,
                        ),
                        child: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 16.w,
                          color: isLiked
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$likeCount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => controller.toggleCommentDislike(
                          comment.id,
                          comment.commentLikesCount,
                          comment.commentDislikesCount,
                        ),
                        child: Icon(
                          isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_outlined,
                          size: 16.w,
                          color: isDisliked
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$dislikeCount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => controller.replyToComment(
                          comment.id,
                          comment.commenterUsername,
                        ),
                        child: Icon(
                          Icons.comment_outlined,
                          size: 16.w,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          if (isMyComment)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'edit') {
                  controller.editComment(comment);
                } else if (value == 'delete') {
                  controller.deleteComment(comment.id);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          else
            const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildReplyItem(ContentCommentReply reply) {
    final currentUserId = Get.find<AuthService>().currentUserId.value;
    final isMyReply = currentUserId != null && reply.commenter == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 16.w, 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundImage: reply.commenterProfile != null
                    ? CachedNetworkImageProvider(reply.commenterProfile!)
                          as ImageProvider
                    : const AssetImage('assets/images/user_avatar.png'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@${reply.commenterUsername}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          reply.createdAtTimeAgo ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(reply.comment, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(height: 12.h),
                    Obx(() {
                      final isLiked =
                          controller.commentIsLikedMap[reply.id]?.value ??
                          false;
                      final isDisliked =
                          controller.commentIsDislikedMap[reply.id]?.value ??
                          false;
                      final likeCount =
                          controller.commentLikeCountMap[reply.id]?.value ??
                          (int.tryParse(reply.commentLikesCount ?? '0') ?? 0);
                      final dislikeCount =
                          controller.commentDislikeCountMap[reply.id]?.value ??
                          (int.tryParse(reply.commentDislikesCount ?? '0') ??
                              0);

                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleCommentLike(
                              reply.id,
                              reply.commentLikesCount,
                              reply.commentDislikesCount,
                            ),
                            child: Icon(
                              isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 14.w,
                              color: isLiked
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$likeCount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          GestureDetector(
                            onTap: () => controller.toggleCommentDislike(
                              reply.id,
                              reply.commentLikesCount,
                              reply.commentDislikesCount,
                            ),
                            child: Icon(
                              isDisliked
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_outlined,
                              size: 14.w,
                              color: isDisliked
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$dislikeCount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          GestureDetector(
                            onTap: () => controller.replyToComment(
                              reply.id,
                              reply.commenterUsername,
                            ),
                            child: Icon(
                              Icons.comment_outlined,
                              size: 14.w,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              if (isMyReply)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      controller.editReply(reply);
                    } else if (value == 'delete') {
                      controller.deleteReplyComment(reply.id);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                )
              else
                const Icon(Icons.more_vert, color: AppColors.textSecondary),
            ],
          ),
        ),
        if (reply.replies != null && reply.replies!.isNotEmpty)
          Column(
            children: reply.replies!.map((r) => _buildReplyItem(r)).toList(),
          ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage: const AssetImage('assets/images/user_avatar.png'),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_emotions_outlined,
                    color: AppColors.textSecondary,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() {
                      String hint = 'Add your thoughts';
                      if (controller.editingCommentId.value != null) {
                        hint = 'Edit your comment...';
                      } else if (controller.replyingToCommentId.value != null) {
                        hint =
                            'Replying to @${controller.replyingToUsername.value}...';
                      }
                      return TextField(
                        controller: controller.commentController,
                        focusNode: controller.commentFocusNode,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                          hintStyle: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                  ),
                  Icon(
                    Icons.card_giftcard,
                    color: AppColors.textSecondary,
                    size: 20.w,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: controller.submitComment,
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.editingCommentId.value != null
                      ? Icons.check
                      : Icons.send,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.editingCommentId.value != null ||
                controller.replyingToCommentId.value != null) {
              return GestureDetector(
                onTap: controller.editingCommentId.value != null
                    ? controller.cancelEdit
                    : controller.cancelReply,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 20.w),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
