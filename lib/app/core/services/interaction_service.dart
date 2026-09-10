import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/core/services/auth_service.dart';
import 'package:glotune/app/data/models/content_comment.dart';

class InteractionService extends GetxService {
  
  Future<bool> toggleLike(int contentId, bool isCurrentlyLiked) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      dynamic response;
      if (isCurrentlyLiked) {
        response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}initial/content/like/delete/$contentId/'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}initial/content/like/'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({"content": contentId}),
        );
      }
      return response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error toggling like: $e");
      return false;
    }
  }

  Future<bool> toggleDislike(int contentId, bool isCurrentlyDisliked) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      dynamic response;
      if (isCurrentlyDisliked) {
        response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}initial/content/dislike/delete/$contentId/'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}initial/content/dislike/'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({"content": contentId}),
        );
      }
      return response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error toggling dislike: $e");
      return false;
    }
  }

  Future<bool> toggleCommentLike(int commentId, bool isCurrentlyLiked) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      dynamic response;
      if (isCurrentlyLiked) {
        response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}riply/comment/like/delete/$commentId/'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}riply/comment/like/'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({"comment_id": commentId}),
        );
      }
      return response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error toggling comment like: $e");
      return false;
    }
  }

  Future<bool> toggleCommentDislike(int commentId, bool isCurrentlyDisliked) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      dynamic response;
      if (isCurrentlyDisliked) {
        response = await apiClient.delete(
          Uri.parse('${ApiConstants.baseUrl}riply/comment/dislike/delete/$commentId/'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await apiClient.post(
          Uri.parse('${ApiConstants.baseUrl}riply/comment/dislike/'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({"comment_id": commentId}),
        );
      }
      return response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error toggling comment dislike: $e");
      return false;
    }
  }

  Future<bool> shareContent(int contentId) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}initial/content/share/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"content": contentId}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error sharing content: $e");
      return false;
    }
  }
  
  Future<bool> recordView(int contentId) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}initial/content/view/create/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"content": contentId}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error recording view: $e");
      return false;
    }
  }

  Future<bool> reportUser(int reportedUserId, String reportType, String reason) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}report/someone-user/create/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "reported_user": reportedUserId,
          "report_type": reportType,
          "reason": reason
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error reporting user: $e");
      return false;
    }
  }

  Future<ContentComment?> postComment(int contentId, String comment) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return null;
    
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}initial/content/comment/create/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "content_id": contentId,
          "comment": comment,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContentComment.fromJson(data);
      } else {
        print("Failed to post comment: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error posting comment: $e");
      return null;
    }
  }

  Future<bool> postReply(int commentId, String text) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConstants.baseUrl}riply/comment/create/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "comment_id": commentId,
          "comment": text,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Failed to post reply: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error posting reply: $e");
      return false;
    }
  }

  Future<ContentComment?> updateComment(int commentId, int contentId, String newComment) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return null;
    
    try {
      final response = await apiClient.patch(
        Uri.parse('${ApiConstants.baseUrl}initial/content/up/del/comment/$commentId/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": commentId,
          "content_id": contentId,
          "content": contentId,
          "comment": newComment,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ContentComment.fromJson(data);
      } else {
        print("Failed to update comment: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error updating comment: $e");
      return null;
    }
  }

  Future<bool> deleteComment(int commentId) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.delete(
        Uri.parse('${ApiConstants.baseUrl}initial/content/up/del/comment/$commentId/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Error deleting comment: $e");
      return false;
    }
  }

  Future<bool> deleteReplyComment(int replyId) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.delete(
        Uri.parse('${ApiConstants.baseUrl}riply/comment/delete/$replyId/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Error deleting reply comment: $e");
      return false;
    }
  }

  Future<bool> editReplyComment(int replyId, int contentId, String newText) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    if (token == null) return false;
    
    try {
      final response = await apiClient.patch(
        Uri.parse('${ApiConstants.baseUrl}riply/comment/delete/$replyId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content_id': contentId,
          'comment': newText,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error editing reply comment: $e");
      return false;
    }
  }

  Future<List<ContentComment>> fetchComments(int contentId) async {
    final authService = Get.find<AuthService>();
    final token = authService.accessToken.value;
    
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await apiClient.get(
        Uri.parse('${ApiConstants.baseUrl}content/$contentId/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final commentsData = data['comments'] as List?;
        if (commentsData != null) {
          return commentsData.map((c) => ContentComment.fromJson(c)).toList();
        }
      } else {
        print("Failed to fetch content details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching content details: $e");
    }
    return [];
  }
}
