import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(radius: 18.r, backgroundImage: const AssetImage('assets/images/user_avatar.png')),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.contactData['name']!, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                Text("Online", style: TextStyle(color: Colors.greenAccent, fontSize: 10.sp)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_outlined, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                bool isMe = msg['isMe'] as bool;
                return _buildMessageBubble(msg['text'] as String, isMe);
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: isMe ? 60.w : 0, right: isMe ? 0 : 60.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.border.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 13.sp),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("12:00 PM", style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 9.sp)),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  const Icon(Icons.done_all, color: Colors.white70, size: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_emotions_outlined, color: AppColors.textSecondary, size: 20.sp),
                  SizedBox(width: 8.w),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Message', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
                    ),
                  ),
                  Icon(Icons.mic_none, color: AppColors.textSecondary, size: 20.sp),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(Icons.send, color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
