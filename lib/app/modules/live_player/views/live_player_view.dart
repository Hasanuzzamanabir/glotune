import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glotune/app/modules/live_player/controllers/live_player_controller.dart';
import 'package:glotune/app/modules/live_player/views/widgets/floating_reactions.dart';

class LivePlayerView extends GetView<LivePlayerController> {
  const LivePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Stream
          Center(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CircularProgressIndicator();
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Text('Error: ${controller.errorMessage.value}', style: const TextStyle(color: Colors.white));
              }
              if (!controller.isEngineInitialized.value) {
                return const Text('Initializing...', style: TextStyle(color: Colors.white));
              }
              if (controller.remoteUids.isEmpty) {
                return const Text(
                  'Waiting for host to broadcast...',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                );
              }
              // Render the first remote user (host)
              return AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: controller.engine,
                  canvas: VideoCanvas(uid: controller.remoteUids.first),
                  connection: RtcConnection(channelId: controller.roomId),
                ),
              );
            }),
          ),
          
          // Overlays
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                const Spacer(),
                
                // Comments
                _buildMessageList(),
                
                // Bottom interactions
                _buildInteractionArea(),
              ],
            ),
          ),

          // Floating Reactions Overlay
          Positioned.fill(
            child: FloatingReactions(reactionStream: controller.reactionStream),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Obx(() => CircleAvatar(
            radius: 18.r,
            backgroundImage: controller.hostProfilePic.value.isNotEmpty
                ? CachedNetworkImageProvider(controller.hostProfilePic.value) as ImageProvider
                : const AssetImage('assets/images/user_avatar.png'),
          )),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.title.value, 
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                Row(
                  children: [
                    const Icon(Icons.group, color: Colors.white, size: 12),
                    SizedBox(width: 4.w),
                    Obx(() => Text("${controller.memberCount.value}", style: TextStyle(color: Colors.white, fontSize: 10.sp))),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 150.h,
        child: Obx(() {
          return ListView.builder(
            itemCount: controller.liveMessages.length,
            reverse: true, // Show latest messages at the bottom
            itemBuilder: (context, index) {
              final msg = controller.liveMessages[index];
              final username = msg['user']?['username'] ?? "User";
              final text = msg['message'] ?? "";
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$username: ", style: TextStyle(color: Colors.yellow, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildInteractionArea() {
    final messageController = TextEditingController();
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        )
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: TextField(
                controller: messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white70),
                    onPressed: () {
                      if (messageController.text.trim().isNotEmpty) {
                        controller.sendLiveMessage(messageController.text);
                        messageController.clear();
                      }
                    },
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    controller.sendLiveMessage(val);
                    messageController.clear();
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.sendReaction('like'),
            child: Icon(Icons.thumb_up_alt_outlined, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _showGiftBottomSheet,
            child: Icon(Icons.card_giftcard, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.sendReaction('heart'),
            child: Icon(Icons.favorite_border, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.shareLive(),
            child: Icon(Icons.share, color: Colors.white, size: 24.sp),
          ),
        ],
      ),
    );
  }

  void _showGiftBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text("Send a Gift", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGiftOption("Heart", "heart", 5, Icons.favorite, Colors.red),
                  SizedBox(width: 16.w),
                  _buildGiftOption("Rose", "rose", 10, Icons.local_florist, Colors.pink),
                  SizedBox(width: 16.w),
                  _buildGiftOption("Galaxy", "galaxy", 25, Icons.brightness_3, Colors.deepPurple),
                  SizedBox(width: 16.w),
                  _buildGiftOption("Diamond", "diamond", 50, Icons.diamond, Colors.blue),
                  SizedBox(width: 16.w),
                  _buildGiftOption("Crown", "crown", 100, Icons.workspace_premium, Colors.amber),
                ],
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftOption(String label, String giftType, int cost, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => controller.sendGift(giftType),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, color: Colors.orange, size: 12.sp),
              SizedBox(width: 2.w),
              Text("$cost", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
