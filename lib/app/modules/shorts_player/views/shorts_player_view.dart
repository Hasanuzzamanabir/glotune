import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/shorts_player_controller.dart';
import 'package:glotune/app/data/models/content_list.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/data/models/content_comment.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class ShortsPlayerView extends GetView<ShortsPlayerController> {
  const ShortsPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.shortsList.isEmpty) {
          return const Center(
            child: Text(
              "No shorts available",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return PageView.builder(
          controller: controller.pageController,
          scrollDirection: Axis.vertical,
          itemCount: controller.shortsList.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            final short = controller.shortsList[index];
            return _buildShortPage(context, index, short);
          },
        );
      }),
    );
  }

  Widget _buildShortPage(BuildContext context, int index, ContentList short) {
    return GetBuilder<ShortsPlayerController>(
      id: index,
      builder: (_) {
        final videoController = controller.videoControllers[index];
        final isInitialized = videoController?.value.isInitialized ?? false;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Video Player Background
            GestureDetector(
              onTap: () => controller.togglePlayPause(index),
              child: Container(
                color: Colors.black,
                child: isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: videoController!.value.size.width,
                          height: videoController.value.size.height,
                          child: VideoPlayer(videoController),
                        ),
                      )
                    : _buildPlaceholder(short),
              ),
            ),

            // Play/Pause Icon overlay (shows briefly when paused)
            if (isInitialized && !videoController!.value.isPlaying)
              Center(
                child: GestureDetector(
                  onTap: () => controller.togglePlayPause(index),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48.w,
                    ),
                  ),
                ),
              ),

            // Top Gradient & Back Button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 300.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Video Info (Bottom Left)
            Positioned(
              bottom: 20.h,
              left: 16.w,
              right: 80.w, // Leave room for action buttons
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundImage: short.authorProfile != null
                            ? CachedNetworkImageProvider(short.authorProfile!)
                                  as ImageProvider
                            : const AssetImage('assets/images/user_avatar.png'),
                        backgroundColor: Colors.grey[800],
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        short.authorName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Subscribe",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    short.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (short.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      short.description,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Action Buttons (Bottom Right)
            Positioned(
              bottom: 20.h,
              right: 8.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => _buildAction(
                      controller.isLikedMap[short.id]?.value ?? false
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined,
                      '${controller.likeCountMap[short.id]?.value ?? short.likeCount ?? 0}',
                      onTap: () => controller.toggleLike(index),
                      isActive: controller.isLikedMap[short.id]?.value ?? false,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Obx(
                    () => _buildAction(
                      controller.isDislikedMap[short.id]?.value ?? false
                          ? Icons.thumb_down
                          : Icons.thumb_down_alt_outlined,
                      '${controller.dislikeCountMap[short.id]?.value ?? short.dislikeCount ?? 0}',
                      onTap: () => controller.toggleDislike(index),
                      isActive:
                          controller.isDislikedMap[short.id]?.value ?? false,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildAction(
                    Icons.comment_outlined,
                    short.commentCount ?? "Comment",
                    onTap: () => _showComments(index),
                  ),
                  SizedBox(height: 20.h),
                  Obx(
                    () => _buildAction(
                      Icons.share_outlined,
                      '${controller.shareCountMap[short.id]?.value ?? short.shareCount}',
                      onTap: () => controller.shareContent(index),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: short.thumbnail != null
                          ? Image.network(short.thumbnail!, fit: BoxFit.cover)
                          : const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAction(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.white,
            size: 30.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ContentList short) {
    if (short.thumbnail != null) {
      return Image.network(
        short.thumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  void _showComments(int index) {
    Get.bottomSheet(
      _ShortsCommentsOverlay(controller: controller, index: index),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _ShortsCommentsOverlay extends StatelessWidget {
  final ShortsPlayerController controller;
  final int index;

  const _ShortsCommentsOverlay({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final short = controller.shortsList[index];
    final commentsList =
        controller.commentsMap[short.id] ?? <ContentComment>[].obs;

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
                  if (commentsList.isEmpty) {
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
                    itemCount: commentsList.length,
                    itemBuilder: (context, idx) {
                      return _buildCommentItem(commentsList[idx]);
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
    final short = controller.shortsList[index];

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
                  controller.deleteComment(short.id, comment.id);
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
                      controller.deleteReplyComment(
                        controller.shortsList[index].id,
                        reply.id,
                      );
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
            onTap: () => controller.submitComment(index),
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
