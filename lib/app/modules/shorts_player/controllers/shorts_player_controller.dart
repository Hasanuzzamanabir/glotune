import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:glotune/app/core/services/interaction_service.dart';
import 'package:glotune/app/data/models/content_list.dart';
import 'package:glotune/app/data/models/content_comment.dart';

class ShortsPlayerController extends GetxController {
  late PageController pageController;
  final shortsList = <ContentList>[].obs;
  final currentIndex = 0.obs;
  
  // Map of index to VideoPlayerController
  final Map<int, VideoPlayerController> videoControllers = {};
  
  // Interaction states for shorts
  final Map<int, RxBool> isLikedMap = {};
  final Map<int, RxInt> likeCountMap = {};
  final Map<int, RxBool> isDislikedMap = {};
  final Map<int, RxInt> dislikeCountMap = {};
  final Map<int, RxInt> shareCountMap = {};
  
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();
  final Map<int, RxList<ContentComment>> commentsMap = {};
  final RxnInt editingCommentId = RxnInt();
  final replyingToCommentId = RxnInt();
  final replyingToUsername = RxnString();
  final RxBool isEditingReply = false.obs;
  
  // Comment Interaction State
  final commentIsLikedMap = <int, RxBool>{}.obs;
  final commentIsDislikedMap = <int, RxBool>{}.obs;
  final commentLikeCountMap = <int, RxInt>{}.obs;
  final commentDislikeCountMap = <int, RxInt>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['shortsList'] != null) {
        shortsList.value = List<ContentList>.from(args['shortsList']);
        for (var short in shortsList) {
          isLikedMap[short.id] = false.obs;
          likeCountMap[short.id] = (int.tryParse(short.likeCount ?? '0') ?? 0).obs;
          isDislikedMap[short.id] = false.obs;
          dislikeCountMap[short.id] = (int.tryParse(short.dislikeCount ?? '0') ?? 0).obs;
          shareCountMap[short.id] = (short.shareCount).obs;
          commentsMap[short.id] = <ContentComment>[].obs;
        }
      }
      if (args['initialIndex'] != null) {
        currentIndex.value = args['initialIndex'] as int;
      }
    }
    
    pageController = PageController(initialPage: currentIndex.value);
    _initializeVideo(currentIndex.value);
  }
  
  void onPageChanged(int index) {
    videoControllers[currentIndex.value]?.pause();
    currentIndex.value = index;
    
    _initializeVideo(index);
    
    if (index + 1 < shortsList.length) {
      _initializeVideo(index + 1, play: false);
    }
    if (index - 1 >= 0) {
      _initializeVideo(index - 1, play: false);
    }
    
    _cleanupOldVideos(index);
  }
  
  Future<void> _initializeVideo(int index, {bool play = true}) async {
    if (index < 0 || index >= shortsList.length) return;
    final short = shortsList[index];

    if (videoControllers.containsKey(index)) {
      if (play) {
        videoControllers[index]?.play();
        Get.find<InteractionService>().recordView(short.id);
      }
      return;
    }
    
    if (short.video != null) {
      String videoUrl = short.video!;
      // Force HTTPS if it's using the cloudflare tunnel over HTTP to bypass cleartext blocks
      if (videoUrl.startsWith('http://')) {
        videoUrl = videoUrl.replaceFirst('http://', 'https://');
      }
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      videoControllers[index] = controller;
      try {
        await controller.initialize();
        controller.setLooping(true);
        if (play && currentIndex.value == index) {
          controller.play();
          Get.find<InteractionService>().recordView(short.id);
        }
        update([index]);
      } catch (e) {
        print("Error initializing video: $e");
      }
    }
    
    _loadComments(index);
  }

  Future<void> _loadComments(int index) async {
    if (index < 0 || index >= shortsList.length) return;
    final short = shortsList[index];
    final fetchedComments = await Get.find<InteractionService>().fetchComments(short.id);
    commentsMap[short.id]?.assignAll(fetchedComments);
  }
  
  void _cleanupOldVideos(int currentIndex) {
    final keysToRemove = <int>[];
    videoControllers.forEach((index, controller) {
      if ((index - currentIndex).abs() > 2) {
        controller.dispose();
        keysToRemove.add(index);
      }
    });
    
    for (var key in keysToRemove) {
      videoControllers.remove(key);
    }
  }
  
  void togglePlayPause(int index) {
    final controller = videoControllers[index];
    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      update([index]);
    }
  }
  
  @override
  void onClose() {
    pageController.dispose();
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    commentController.dispose();
    commentFocusNode.dispose();
    super.onClose();
  }

  Future<void> toggleLike(int index) async {
    if (index < 0 || index >= shortsList.length) return;
    final short = shortsList[index];
    final isLiked = isLikedMap[short.id]!;
    final likeCount = likeCountMap[short.id]!;

    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    if (isLiked.value) {
      likeCount.value++;
    } else {
      likeCount.value--;
    }

    final success = await Get.find<InteractionService>().toggleLike(short.id, wasLiked);
    if (!success) {
      isLiked.value = wasLiked;
      if (wasLiked) {
        likeCount.value++;
      } else {
        likeCount.value--;
      }
    }
  }

  Future<void> toggleDislike(int index) async {
    if (index < 0 || index >= shortsList.length) return;
    final short = shortsList[index];
    final isDisliked = isDislikedMap[short.id]!;
    final dislikeCount = dislikeCountMap[short.id]!;

    final wasDisliked = isDisliked.value;
    isDisliked.value = !wasDisliked;
    if (isDisliked.value) {
      dislikeCount.value++;
    } else {
      dislikeCount.value--;
    }

    final success = await Get.find<InteractionService>().toggleDislike(short.id, wasDisliked);
    if (!success) {
      isDisliked.value = wasDisliked;
      if (wasDisliked) {
        dislikeCount.value++;
      } else {
        dislikeCount.value--;
      }
    }
  }

  Future<void> shareContent(int index) async {
    if (index < 0 || index >= shortsList.length) return;
    final short = shortsList[index];
    
    final linkToShare = short.video ?? "Check out this content on Glotune!";
    Share.share('Check out this short: ${short.title}\n$linkToShare');

    final shareCount = shareCountMap[short.id]!;
    shareCount.value++;

    final success = await Get.find<InteractionService>().shareContent(short.id);
    if (!success) {
      shareCount.value--;
    }
  }

  void editComment(ContentComment comment) {
    cancelReply();
    editingCommentId.value = comment.id;
    isEditingReply.value = false;
    commentController.text = comment.comment;
    commentFocusNode.requestFocus();
  }

  void editReply(ContentCommentReply reply) {
    cancelReply();
    editingCommentId.value = reply.id;
    isEditingReply.value = true;
    commentController.text = reply.comment;
    commentFocusNode.requestFocus();
  }

  void cancelEdit() {
    editingCommentId.value = null;
    isEditingReply.value = false;
    commentController.clear();
    commentFocusNode.unfocus();
  }

  void replyToComment(int targetId, String username) {
    replyingToCommentId.value = targetId;
    replyingToUsername.value = username;
    editingCommentId.value = null;
    commentController.text = '@$username ';
    // Move cursor to the end
    commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: commentController.text.length),
    );
  }

  void cancelReply() {
    replyingToCommentId.value = null;
    replyingToUsername.value = null;
    commentController.clear();
  }

  Future<void> submitComment(int index) async {
    if (index < 0 || index >= shortsList.length) return;
    final short = shortsList[index];
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    
    if (editingCommentId.value != null) {
      bool success = false;
      if (isEditingReply.value) {
        success = await Get.find<InteractionService>().editReplyComment(
          editingCommentId.value!,
          short.id,
          text,
        );
      } else {
        final result = await Get.find<InteractionService>().updateComment(
          editingCommentId.value!,
          short.id,
          text,
        );
        success = result != null;
      }
      
      if (success) {
        _loadComments(short.id);
        cancelEdit();
      } else {
        Get.snackbar("Error", "Failed to update comment");
      }
    } else if (replyingToCommentId.value != null) {
      final targetId = replyingToCommentId.value!;
      final success = await Get.find<InteractionService>().postReply(
        targetId, 
        text,
      );
      if (success) {
        _loadComments(index);
        cancelReply();
      } else {
        Get.snackbar("Error", "Failed to post reply");
      }
    } else {
      final result = await Get.find<InteractionService>().postComment(short.id, text);
      if (result != null) {
        commentsMap[short.id]?.insert(0, result);
        commentController.clear();
      } else {
        Get.snackbar("Error", "Failed to post comment");
      }
    }
  }

  Future<void> deleteComment(int contentId, int commentId) async {
    final success = await Get.find<InteractionService>().deleteComment(commentId);
    if (success) {
      if (commentsMap.containsKey(contentId)) {
        commentsMap[contentId]!.removeWhere((c) => c.id == commentId);
      }
      if (editingCommentId.value == commentId) cancelEdit();
    } else {
      Get.snackbar("Error", "Failed to delete comment");
    }
  }

  Future<void> deleteReplyComment(int contentId, int replyId) async {
    final success = await Get.find<InteractionService>().deleteReplyComment(replyId);
    if (success) {
      _loadComments(contentId);
    } else {
      Get.snackbar("Error", "Failed to delete reply");
    }
  }

  void initCommentInteractions(int id, String? likesStr, String? dislikesStr) {
    if (!commentLikeCountMap.containsKey(id)) {
      commentIsLikedMap[id] = false.obs;
      commentIsDislikedMap[id] = false.obs;
      commentLikeCountMap[id] = (int.tryParse(likesStr ?? '0') ?? 0).obs;
      commentDislikeCountMap[id] = (int.tryParse(dislikesStr ?? '0') ?? 0).obs;
    }
  }

  Future<void> toggleCommentLike(int commentId, String? initialLikesStr, String? initialDislikesStr) async {
    initCommentInteractions(commentId, initialLikesStr, initialDislikesStr);

    final wasLiked = commentIsLikedMap[commentId]?.value ?? false;
    final count = commentLikeCountMap[commentId]?.value ?? 0;
    
    // Optimistic update
    commentIsLikedMap[commentId]?.value = !wasLiked;
    commentLikeCountMap[commentId]?.value = wasLiked ? (count > 0 ? count - 1 : 0) : (count + 1);

    // If un-disliking as part of liking
    final wasDisliked = commentIsDislikedMap[commentId]?.value ?? false;
    if (!wasLiked && wasDisliked) {
       await toggleCommentDislike(commentId, initialLikesStr, initialDislikesStr);
    }

    final success = await Get.find<InteractionService>().toggleCommentLike(commentId, wasLiked);
    
    if (!success) {
      // Revert
      commentIsLikedMap[commentId]?.value = wasLiked;
      commentLikeCountMap[commentId]?.value = count;
    }
  }

  Future<void> toggleCommentDislike(int commentId, String? initialLikesStr, String? initialDislikesStr) async {
    initCommentInteractions(commentId, initialLikesStr, initialDislikesStr);

    final wasDisliked = commentIsDislikedMap[commentId]?.value ?? false;
    final count = commentDislikeCountMap[commentId]?.value ?? 0;
    
    // Optimistic update
    commentIsDislikedMap[commentId]?.value = !wasDisliked;
    commentDislikeCountMap[commentId]?.value = wasDisliked ? (count > 0 ? count - 1 : 0) : (count + 1);

    // If un-liking as part of disliking
    final wasLiked = commentIsLikedMap[commentId]?.value ?? false;
    if (!wasDisliked && wasLiked) {
       await toggleCommentLike(commentId, initialLikesStr, initialDislikesStr);
    }

    final success = await Get.find<InteractionService>().toggleCommentDislike(commentId, wasDisliked);
    
    if (!success) {
      // Revert
      commentIsDislikedMap[commentId]?.value = wasDisliked;
      commentDislikeCountMap[commentId]?.value = count;
    }
  }
}
