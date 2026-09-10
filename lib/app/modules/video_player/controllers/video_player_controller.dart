import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:glotune/app/core/services/interaction_service.dart';
import 'package:glotune/app/data/models/content_list.dart';
import 'package:glotune/app/data/models/content_comment.dart';

class VideoPlayerController extends GetxController {
  final isSubscribed = false.obs;
  final isSubscribeLoading = false.obs;
  final isLiked = false.obs;
  final likeCount = 0.obs;
  
  final isDisliked = false.obs;
  final dislikeCount = 0.obs;

  final shareCount = 0.obs;

  ContentList? videoData;
  vp.VideoPlayerController? vpController;
  ChewieController? chewieController;
  final isVideoInitialized = false.obs;
  final isPlaying = false.obs;

  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();
  final comments = <ContentComment>[].obs;
  final RxnInt editingCommentId = RxnInt();
  final RxnInt replyingToCommentId = RxnInt();
  final RxnString replyingToUsername = RxnString();
  final RxBool isEditingReply = false.obs;

  // Comment Interaction State
  final commentIsLikedMap = <int, RxBool>{}.obs;
  final commentIsDislikedMap = <int, RxBool>{}.obs;
  final commentLikeCountMap = <int, RxInt>{}.obs;
  final commentDislikeCountMap = <int, RxInt>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is ContentList) {
      videoData = Get.arguments as ContentList;
      if (videoData!.likeCount != null) {
        likeCount.value = int.tryParse(videoData!.likeCount!) ?? 0;
      }
      if (videoData!.dislikeCount != null) {
        dislikeCount.value = int.tryParse(videoData!.dislikeCount!) ?? 0;
      }
      shareCount.value = videoData!.shareCount;
      if (videoData!.video != null && videoData!.video!.isNotEmpty) {
        _initializeVideoPlayer(videoData!.video!);
      }
      _fetchAuthorProfile(videoData!.author);
      _loadComments(videoData!.id);
    }
  }

  Future<void> _fetchAuthorProfile(int authorId) async {
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;

      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}others/users/profile/$authorId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isSub = data['is_subscribed'] ?? data['is_subscribe'] ?? data['isSubscribe'];
        if (isSub != null) {
          final isSubStr = isSub.toString().toLowerCase();
          isSubscribed.value = isSub == true || isSubStr == 'true' || isSubStr == '1';
        }
      }
    } catch (e) {
      print("Error fetching author profile: $e");
    }
  }

  Future<void> _loadComments(int contentId) async {
    final fetchedComments = await Get.find<InteractionService>().fetchComments(contentId);
    comments.assignAll(fetchedComments);
  }

  void _initializeVideoPlayer(String url) {
    // If the URL is http (e.g., from Cloudflare tunnel), try to use https to avoid cleartext traffic errors.
    final secureUrl = url.replaceFirst('http://', 'https://');
    
    vpController = vp.VideoPlayerController.networkUrl(Uri.parse(secureUrl))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: vpController!,
          autoPlay: true,
          looping: false,
          aspectRatio: vpController!.value.aspectRatio,
        );
        isVideoInitialized.value = true;
      }).catchError((error) {
        print("Error initializing video player: $error");
        // Optionally handle error state here
      });
      
    vpController!.addListener(() {
      if (vpController!.value.isPlaying != isPlaying.value) {
        isPlaying.value = vpController!.value.isPlaying;
        if (isPlaying.value && videoData != null) {
          Get.find<InteractionService>().recordView(videoData!.id);
        }
      }
    });
  }

  void playVideo() {
    vpController?.play();
  }

  void pauseVideo() {
    vpController?.pause();
  }

  void togglePlay() {
    if (vpController != null) {
      if (vpController!.value.isPlaying) {
        vpController!.pause();
      } else {
        vpController!.play();
      }
    }
  }

  @override
  void onClose() {
    vpController?.dispose();
    chewieController?.dispose();
    commentController.dispose();
    commentFocusNode.dispose();
    super.onClose();
  }
  
  Future<void> toggleSubscribe() async {
    if (isSubscribeLoading.value || videoData == null) return;

    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) {
      Get.snackbar('Error', 'Please login to subscribe');
      return;
    }

    isSubscribeLoading.value = true;
    final authorId = videoData!.author;

    try {
      if (isSubscribed.value) {
        // Unsubscribe
        final response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}chanale/unsubscribe/$authorId/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          isSubscribed.value = false;
        } else {
          Get.snackbar('Error', 'Failed to unsubscribe: ${response.statusCode}');
        }
      } else {
        // Subscribe
        final response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}chanale/subscribe/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'user_id': authorId, 'bell_notification': false}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          isSubscribed.value = true;
        } else {
          Get.snackbar('Error', 'Failed to subscribe: ${response.statusCode}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
      print('Subscribe error: $e');
    } finally {
      isSubscribeLoading.value = false;
    }
  }
  
  Future<void> toggleLike() async {
    if (videoData == null) return;
    
    // Optimistic update
    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    if (isLiked.value) {
      likeCount.value++;
    } else {
      likeCount.value--;
    }

    final success = await Get.find<InteractionService>().toggleLike(videoData!.id, wasLiked);
    
    if (!success) {
      // Revert on failure
      isLiked.value = wasLiked;
      if (wasLiked) {
        likeCount.value++;
      } else {
        likeCount.value--;
      }
    }
  }

  Future<void> toggleDislike() async {
    if (videoData == null) return;
    
    // Optimistic update
    final wasDisliked = isDisliked.value;
    isDisliked.value = !wasDisliked;
    if (isDisliked.value) {
      dislikeCount.value++;
    } else {
      dislikeCount.value--;
    }

    final success = await Get.find<InteractionService>().toggleDislike(videoData!.id, wasDisliked);
    
    if (!success) {
      // Revert on failure
      isDisliked.value = wasDisliked;
      if (wasDisliked) {
        dislikeCount.value++;
      } else {
        dislikeCount.value--;
      }
    }
  }

  Future<void> shareContent() async {
    if (videoData == null) return;
    
    final linkToShare = videoData!.video ?? "Check out this content on Glotune!";
    Share.share('Check out this video: ${videoData!.title}\n$linkToShare');

    // Optimistic update
    shareCount.value++;

    final success = await Get.find<InteractionService>().shareContent(videoData!.id);
    
    if (!success) {
      // Revert on failure
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

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || videoData == null) return;
    
    if (editingCommentId.value != null) {
      try {
        bool success = false;
        if (isEditingReply.value) {
          success = await Get.find<InteractionService>().editReplyComment(editingCommentId.value!, videoData!.id, text);
        } else {
          final result = await Get.find<InteractionService>().updateComment(editingCommentId.value!, videoData!.id, text);
          success = result != null;
        }
        
        if (success) {
          _loadComments(videoData!.id);
          cancelEdit();
        } else {
          Get.snackbar("Error", "Failed to update comment");
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to update comment");
      }
    } else if (replyingToCommentId.value != null) {
      final targetId = replyingToCommentId.value!;
      final success = await Get.find<InteractionService>().postReply(
        targetId, 
        text,
      );
      if (success) {
        // Find the comment in the list and add the reply if the model supports it,
        // or just fetch all comments again to ensure consistency.
        _loadComments(videoData!.id);
        cancelReply();
      } else {
        Get.snackbar("Error", "Failed to post reply");
      }
    } else {
      final result = await Get.find<InteractionService>().postComment(videoData!.id, text);
      if (result != null) {
        comments.insert(0, result);
        commentController.clear();
      } else {
        Get.snackbar("Error", "Failed to post comment");
      }
    }
  }

  Future<void> deleteComment(int commentId) async {
    final success = await Get.find<InteractionService>().deleteComment(commentId);
    if (success) {
      comments.removeWhere((c) => c.id == commentId);
      if (editingCommentId.value == commentId) cancelEdit();
    } else {
      Get.snackbar("Error", "Failed to delete comment");
    }
  }

  Future<void> deleteReplyComment(int replyId) async {
    final success = await Get.find<InteractionService>().deleteReplyComment(replyId);
    if (success) {
      if (videoData != null) {
        _loadComments(videoData!.id);
      }
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
