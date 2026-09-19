import 'dart:async';
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
                return Text(
                  'Error: ${controller.errorMessage.value}',
                  style: const TextStyle(color: Colors.white),
                );
              }
              if (!controller.isEngineInitialized.value) {
                return const Text(
                  'Initializing...',
                  style: TextStyle(color: Colors.white),
                );
              }
              final hasRemote = controller.remoteUids.isNotEmpty;
              final isCo = controller.isCohost.value;

              if (!hasRemote) {
                if (isCo) {
                  // Only local co-host active so far, waiting for host stream
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: controller.engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                      Positioned(
                        top: 50.h,
                        left: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "You (Co-Host) • Waiting for Host...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const Text(
                  'Waiting for host to broadcast...',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                );
              }

              // Guaranteed hasRemote is true (controller.remoteUids is not empty)
              final totalBroadcasters = controller.remoteUids.length + (isCo ? 1 : 0);

              if (totalBroadcasters == 1) {
                // Single broadcaster (host)
                return AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: controller.engine,
                    canvas: VideoCanvas(uid: controller.remoteUids.first),
                    connection: RtcConnection(channelId: controller.roomId),
                  ),
                );
              }

              // Multiple broadcasters: Host in top half, other participants in bottom half
              final hostUid = controller.remoteUids.first;
              final otherRemoteUids = controller.remoteUids.length > 1
                  ? controller.remoteUids.sublist(1)
                  : <int>[];

              return Column(
                children: [
                  // Top half: Host
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: controller.engine,
                              canvas: VideoCanvas(uid: hostUid),
                              connection: RtcConnection(channelId: controller.roomId),
                            ),
                          ),
                          Positioned(
                            top: 50.h,
                            left: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[800],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                "Host",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Separation line
                  Container(height: 2.h, color: Colors.white24),

                  // Bottom half: Other participants / Co-host
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: _buildPlayerParticipantsBottomHalf(
                        otherRemoteUids: otherRemoteUids,
                        isCohost: isCo,
                      ),
                    ),
                  ),
                ],
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

  Widget _buildPlayerParticipantsBottomHalf({
    required List<int> otherRemoteUids,
    required bool isCohost,
  }) {
    if (isCohost && otherRemoteUids.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: controller.engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                "You (Co-Host)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final List<Widget> guestTiles = [];

    for (final uid in otherRemoteUids) {
      guestTiles.add(
        Stack(
          fit: StackFit.expand,
          children: [
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: controller.roomId),
              ),
            ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "Guest",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isCohost) {
      guestTiles.add(
        Stack(
          fit: StackFit.expand,
          children: [
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: controller.engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  "You (Co-Host)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (guestTiles.isEmpty) {
      return const SizedBox.shrink();
    }

    if (guestTiles.length == 1) {
      return guestTiles.first;
    } else if (guestTiles.length == 2) {
      return Row(
        children: guestTiles.map((tile) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.all(0.5.w),
              child: tile,
            ),
          );
        }).toList(),
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: guestTiles.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(0.5),
            child: guestTiles[index],
          );
        },
      );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Obx(
            () => CircleAvatar(
              radius: 18.r,
              backgroundImage: controller.hostProfilePic.value.isNotEmpty
                  ? CachedNetworkImageProvider(controller.hostProfilePic.value)
                        as ImageProvider
                  : const AssetImage('assets/images/user_avatar.png'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.title.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, color: Colors.white, size: 12),
                    SizedBox(width: 4.w),
                    Obx(
                      () => Text(
                        "${controller.memberCount.value}",
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.isCohost.value) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam, color: Colors.white, size: 12),
                    SizedBox(width: 4.w),
                    Text("CO-HOST", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }
            return GestureDetector(
              onTap: controller.requestToStream,
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white30, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, color: Colors.white, size: 12),
                    SizedBox(width: 4.w),
                    Text("Join Live", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }),
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
              final isSystem = msg is Map && (msg['is_system'] == true || msg['type'] == 'member_action');
              final text = (msg is Map
                      ? (msg['message'] ?? msg['content'] ?? msg['text'])
                      : msg.toString()) ??
                  "";

              if (isSystem) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white12, width: 0.5),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final userObj = msg is Map
                  ? (msg['user'] is Map ? msg['user'] : msg)
                  : {};
              final username = userObj['username'] ??
                  userObj['full_name'] ??
                  userObj['name'] ??
                  "User";
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$username: ",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
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
    Timer? typingDebounceTimer;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temporary message banner from socket
          Obx(() {
            if (controller.temporaryNotice.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.amberAccent, size: 13.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        controller.temporaryNotice.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Typing indicator banner
          Obx(() {
            if (controller.typingNotice.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 10.w,
                    height: 10.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.amberAccent,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    controller.typingNotice.value,
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
                            controller.sendSocketTyping(false);
                            controller.sendLiveMessage(messageController.text);
                            messageController.clear();
                          }
                        },
                      ),
                    ),
                    onChanged: (val) {
                      if (val.trim().isNotEmpty) {
                        controller.sendSocketTyping(true);
                        typingDebounceTimer?.cancel();
                        typingDebounceTimer = Timer(const Duration(seconds: 2), () {
                          controller.sendSocketTyping(false);
                        });
                      } else {
                        controller.sendSocketTyping(false);
                      }
                    },
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        controller.sendSocketTyping(false);
                        controller.sendLiveMessage(val);
                        messageController.clear();
                      }
                    },
                  ),
                ),
              ),
          SizedBox(width: 8.w),
          Obx(() {
            if (!controller.isCohost.value) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => controller.toggleMic(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: controller.isMicMuted.value ? Colors.redAccent : Colors.indigoAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isMicMuted.value ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => controller.toggleCamera(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: controller.isCamOff.value ? Colors.redAccent : Colors.indigoAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isCamOff.value ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            );
          }),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print("[LivePlayer] Tapped like button");
              controller.sendReaction('like');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Icon(
                Icons.thumb_up_alt_outlined,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _showGiftBottomSheet,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Icon(Icons.card_giftcard, color: Colors.white, size: 26.sp),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print("[LivePlayer] Tapped heart button");
              controller.sendReaction('heart');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.shareLive(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Icon(Icons.share, color: Colors.white, size: 26.sp),
            ),
          ),
        ],
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
            Text(
              "Send a Gift",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGiftOption(
                    "Heart",
                    "heart",
                    5,
                    Icons.favorite,
                    Colors.red,
                  ),
                  SizedBox(width: 16.w),
                  _buildGiftOption(
                    "Rose",
                    "rose",
                    10,
                    Icons.local_florist,
                    Colors.pink,
                  ),
                  SizedBox(width: 16.w),
                  _buildGiftOption(
                    "Galaxy",
                    "galaxy",
                    25,
                    Icons.brightness_3,
                    Colors.deepPurple,
                  ),
                  SizedBox(width: 16.w),
                  _buildGiftOption(
                    "Diamond",
                    "diamond",
                    50,
                    Icons.diamond,
                    Colors.blue,
                  ),
                  SizedBox(width: 16.w),
                  _buildGiftOption(
                    "Crown",
                    "crown",
                    100,
                    Icons.workspace_premium,
                    Colors.amber,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftOption(
    String label,
    String giftType,
    int cost,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => controller.sendGift(giftType),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, color: Colors.orange, size: 12.sp),
              SizedBox(width: 2.w),
              Text(
                "$cost",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
