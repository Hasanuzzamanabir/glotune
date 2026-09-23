import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../../controllers/create_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:glotune/app/modules/live_player/views/widgets/floating_reactions.dart';

class LiveStreamView extends GetView<CreateController> {
  const LiveStreamView({super.key});

  static const Color wineBackground = Color(0xFF70111A);
  static const Color darkPillBg = Color(0x991E0507);
  static const Color lightPeachPillBg = Color(0xFFE8D5CE);
  static const Color yellowAccent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    if (controller.liveRoomId.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchLiveParticipants();
      });
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.minimizeToPip(context);
        }
      },
      child: Scaffold(
        backgroundColor: wineBackground,
        body: Stack(
          children: [
            // Background Video & Overlays
            SafeArea(
              bottom: true,
              top: true,
              child: Column(
                children: [
                  // Top Navigation / Header (Row 1 & Row 2)
                  _buildTopHeader(context),

                  SizedBox(height: 6.h),

                  // Middle Video Area
                  Expanded(
                    child: Stack(
                      children: [
                        // The Video Feed
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildVideoStream(),
                                // Smooth gradient overlay at the bottom of the video
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 160.h,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          wineBackground.withValues(alpha: 0.6),
                                          wineBackground,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Temporary socket notice
                        Positioned(
                          top: 8.h,
                          left: 12.w,
                          right: 12.w,
                          child: Obx(() {
                            if (controller.temporaryNotice.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: yellowAccent.withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: yellowAccent,
                                      size: 13.sp,
                                    ),
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
                        ),

                        // Typing Notice banner
                        Positioned(
                          top: 40.h,
                          left: 12.w,
                          child: Obx(() {
                            if (controller.typingNotice.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              children: [
                                SizedBox(
                                  width: 10.w,
                                  height: 10.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: yellowAccent,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  controller.typingNotice.value,
                                  style: TextStyle(
                                    color: yellowAccent,
                                    fontSize: 11.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),

                        // Comments List floating on the lower video area
                        Positioned(
                          bottom: 4.h,
                          left: 12.w,
                          right: 60.w,
                          height: 170.h,
                          child: _buildCommentsSection(),
                        ),
                      ],
                    ),
                  ),

                  // Host Control Panel Box (Settings, Add Guest, Game, Comments, Pause Live)
                  _buildControlBox(context),

                  // Bottom Battle/Game Mode Selector Row (Shown ONLY when Game is tapped)
                  Obx(() {
                    if (!controller.isGameModesVisible.value) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGameModeRow(),
                        SizedBox(height: 6.h),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Floating Reactions Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: FloatingReactions(
                  reactionStream: controller.reactionStream,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Top Header (Row 1 & Row 2)
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Column(
        children: [
          // Row 1: Profile Pill, Viewer Avatars Stack, Share, Close
          Row(
            children: [
              // Host Profile Pill (White Pill)
              _buildHostProfilePill(),

              const Spacer(),

              // Overlapping Viewers Avatar Stack
              _buildViewersStack(),

              SizedBox(width: 8.w),

              // Share Button with 349 Badge
              // _buildShareButton(),
              SizedBox(width: 8.w),

              // Close / End Button
              GestureDetector(
                onTap: () => _showEndStreamDialog(),
                child: Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Row 2: Search Bar, Cloud Upload, Flag, GloTune Banner
          Row(
            children: [
              // Search @username Pill
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () => _showInviteGuests(),
                  child: Container(
                    height: 34.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "@username",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11.sp,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.search, color: Colors.white54, size: 16.sp),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Cloud Upload Icon
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    "Cloud Recording",
                    "Stream is automatically synced with cloud.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                },
                child: Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.white70,
                    size: 18.sp,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Flag Icon
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    "Report",
                    "Safety and moderation options are available in settings.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                },
                child: Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    color: Colors.white70,
                    size: 18.sp,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // GloTune Number one banner
              Expanded(
                flex: 5,
                child: Container(
                  height: 34.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF6D00)],
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "GloTune Number one creat",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Host Profile Pill (White rounded container)
  Widget _buildHostProfilePill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final pic = controller.userProfile.value?.profilePictureUrl;
            return CircleAvatar(
              radius: 14.r,
              backgroundImage: (pic != null && pic.isNotEmpty)
                  ? NetworkImage(pic)
                  : const AssetImage('assets/images/user_avatar.png')
                        as ImageProvider,
            );
          }),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final user = controller.userProfile.value;
                final name =
                    (user?.fullName != null && user!.fullName!.isNotEmpty)
                    ? user.fullName!
                    : (controller.liveTitle.value.isNotEmpty
                          ? controller.liveTitle.value
                          : "Angelina M");
                return Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 9.sp),
                  SizedBox(width: 2.w),
                  Obx(() {
                    final count = controller.liveMemberCount.value;
                    return Text(
                      count > 0 ? "${count}k" : "283k",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.red, size: 9.sp),
                Text(
                  "Follow",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
    );
  }

  // MARK: - Overlapping Viewers Avatar Stack (Real Socket / API Data)
  Widget _buildViewersStack() {
    return Obx(() {
      final count = controller.liveMemberCount.value;

      // Extract real viewer avatar URLs from controller.liveMembers
      final viewerImages = <String>[];
      for (final member in controller.liveMembers) {
        if (member is Map) {
          final user = member['user'] is Map ? member['user'] : member;
          final pic =
              user['profile_picture'] ??
              user['avatar'] ??
              user['image'] ??
              user['profile_image'];
          if (pic != null &&
              pic.toString().trim().isNotEmpty &&
              pic.toString().startsWith('http')) {
            viewerImages.add(pic.toString().trim());
          }
        }
        if (viewerImages.length >= 2) break;
      }

      // If no image from socket/API, remove the image views completely and only show real viewer count
      if (viewerImages.isEmpty) {
        return GestureDetector(
          onTap: () => _showLiveMembersList(),
          child: Container(
            height: 28.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: wineBackground, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.white70,
                  size: 13.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  "$count",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // If there are real viewer images, show only those real images with the count badge
      final overlap = 18.w;
      final totalWidth = 28.w + (viewerImages.length * overlap);

      return GestureDetector(
        onTap: () => _showLiveMembersList(),
        child: SizedBox(
          height: 30.h,
          width: totalWidth,
          child: Stack(
            children: [
              for (int i = 0; i < viewerImages.length; i++)
                Positioned(
                  left: i * overlap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: wineBackground, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 13.r,
                      backgroundColor: Colors.white24,
                      backgroundImage: NetworkImage(viewerImages[i]),
                    ),
                  ),
                ),
              Positioned(
                left: viewerImages.length * overlap,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: wineBackground, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 13.r,
                    backgroundColor: const Color(0xFF4A4A4A),
                    child: Text(
                      "$count",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // MARK: - Share Button with Badge
  // Widget _buildShareButton() {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.snackbar(
  //         "Share",
  //         "Stream link copied to clipboard!",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.white,
  //         colorText: Colors.black,
  //       );
  //     },
  //     child: Stack(
  //       clipBehavior: Clip.none,
  //       children: [
  //         Container(
  //           width: 34.w,
  //           height: 34.h,
  //           decoration: const BoxDecoration(
  //             color: Colors.black54,
  //             shape: BoxShape.circle,
  //           ),
  //           child: const Icon(Icons.reply, color: Colors.white, size: 18),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // MARK: - Video Stream Body (Agora Local & Multi-Guest)
  Widget _buildVideoStream() {
    return Obx(() {
      if (!controller.isLiveEngineInitialized.value ||
          controller.liveEngine == null) {
        // Fallback camera placeholder matching design
        final pic = controller.userProfile.value?.profilePictureUrl;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: (pic != null && pic.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(pic),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage('assets/images/user_avatar.png'),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Connecting camera...",
                      style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // If no remote co-hosts, show single host view
      if (controller.remoteUids.isEmpty) {
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: controller.liveEngine!,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      }

      // If guests connected, split view
      final guests = controller.remoteUids;
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: controller.liveEngine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[800],
                      borderRadius: BorderRadius.circular(6.r),
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
          Container(height: 2.h, color: Colors.white24),
          Expanded(flex: 1, child: _buildParticipantsBottomHalf(guests)),
        ],
      );
    });
  }

  Widget _buildParticipantsBottomHalf(List<int> guests) {
    if (guests.length == 1) {
      final remoteUid = guests.first;
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: controller.liveEngine!,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: controller.liveRoomId.value),
        ),
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: guests.length,
        itemBuilder: (context, index) {
          final uid = guests[index];
          return AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: controller.liveEngine!,
              canvas: VideoCanvas(uid: uid),
              connection: RtcConnection(channelId: controller.liveRoomId.value),
            ),
          );
        },
      );
    }
  }

  // MARK: - Comments & Action Pills Section
  Widget _buildCommentsSection() {
    return Obx(() {
      final messages = controller.liveMessages;

      // If no dynamic messages yet, show the preview mock events from the design
      if (messages.isEmpty) {
        final mockEvents = [
          {
            "user": " ",
            "text": "Stream Has been Started",
            "type": "rose",
            "avatar": " ",
          },
        ];

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: mockEvents.length,
          itemBuilder: (context, index) {
            final item = mockEvents[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: _buildCommentPill(
                username: item['user']!,
                message: item['text']!,
                type: item['type']!,
                avatarUrl: item['avatar']!,
              ),
            );
          },
        );
      }

      // Dynamic messages received from live socket
      return ListView.builder(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final text =
              (msg is Map
                  ? (msg['message'] ?? msg['content'] ?? msg['text'])
                  : msg.toString()) ??
              "";
          final userObj = msg is Map
              ? (msg['user'] is Map ? msg['user'] : msg)
              : {};
          final username =
              userObj['username'] ??
              userObj['full_name'] ??
              userObj['name'] ??
              "Viewer";
          final avatar = userObj['profile_picture'] ?? userObj['avatar'];
          final isAction =
              msg is Map &&
              (msg['type'] == 'member_action' || msg['is_system'] == true);

          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: _buildCommentPill(
              username: "@$username",
              message: text,
              type: isAction
                  ? "join_dark"
                  : (index % 3 == 0 ? "chat_peach" : "chat_white"),
              avatarUrl: avatar?.toString(),
            ),
          );
        },
      );
    });
  }

  // MARK: - Comment Pill Style Factory
  Widget _buildCommentPill({
    required String username,
    required String message,
    required String type,
    String? avatarUrl,
  }) {
    Color bgColor;
    Color userColor;
    Color textColor;

    switch (type) {
      case "rose":
      case "chat_white":
        bgColor = Colors.white.withValues(alpha: 0.95);
        userColor = Colors.black;
        textColor = Colors.black87;
        break;
      case "chat_peach":
        bgColor = lightPeachPillBg.withValues(alpha: 0.95);
        userColor = Colors.black;
        textColor = Colors.black87;
        break;
      case "join_special":
      case "join_dark":
      default:
        bgColor = darkPillBg;
        userColor = yellowAccent;
        textColor = Colors.white;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 9.r,
              backgroundColor: Colors.grey.shade400,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/images/user_avatar.png')
                        as ImageProvider,
            ),
            SizedBox(width: 6.w),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$username ",
                    style: TextStyle(
                      color: userColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Host Control Panel Box (Settings, Add Guest, Game, Comments, Pause Live)
  Widget _buildControlBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Settings
          _buildControlItem(
            iconWidget: Icon(
              Icons.hexagon_outlined,
              color: Colors.white,
              size: 22.sp,
            ),
            label: "Settings",
            onTap: () => _showDetailedSettings(),
          ),

          // Add Guest
          _buildControlItem(
            iconWidget: Icon(
              Icons.person_add_alt_1_outlined,
              color: Colors.white,
              size: 22.sp,
            ),
            label: "Add Guest",
            onTap: () => _showInviteGuests(),
          ),

          // Game (Highlighted Red Container)
          _buildControlItem(
            iconWidget: Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: controller.isGameModesVisible.value
                      ? const Color(0xFFFF2A2A)
                      : const Color(0xFFE5252A),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: controller.isGameModesVisible.value
                      ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.sports_esports,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
            label: "Game",
            onTap: () => controller.toggleGameModes(),
          ),

          // Comments
          _buildControlItem(
            iconWidget: Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            label: "Comments",
            onTap: () => _showCommentInputDialog(context),
          ),

          // Pause Live
          _buildControlItem(
            iconWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 3.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  width: 3.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
            label: "Pause Live",
            onTap: () {
              Get.snackbar(
                "Pause Live",
                "Live stream has been paused. Viewers are notified.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
                colorText: Colors.black,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24.h,
            child: Center(child: iconWidget),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Bottom Battle/Game Mode Selector Row
  Widget _buildGameModeRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Row(
        children: [
          // Box battle (Active / Selected Solid White Pill)
          GestureDetector(
            onTap: () => controller.startBoxBattle(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Box battle",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // 1v1 Outline Pill
          _buildModeOutlinePill(
            "1v1",
            onTap: () => controller.navigateTo("LiveBattle1v1"),
          ),

          SizedBox(width: 8.w),

          // Quiz Outline Pill
          _buildModeOutlinePill(
            "Quiz",
            onTap: () => controller.navigateTo("LiveQuiz"),
          ),

          SizedBox(width: 8.w),

          // 2v2 battle Outline Pill
          _buildModeOutlinePill(
            "2v2 battle",
            onTap: () => controller.navigateTo("LiveBattle2v2"),
          ),

          SizedBox(width: 8.w),

          // Karaoke Outline Pill
          _buildModeOutlinePill(
            "Karaoke",
            onTap: () => controller.navigateTo("LiveKaraoke"),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOutlinePill(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // MARK: - Comment Input Dialog/Sheet
  void _showCommentInputDialog(BuildContext context) {
    final textController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Say something nice...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        controller.sendSocketTyping(val.trim().isNotEmpty);
                      },
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          controller.sendSocketTyping(false);
                          controller.sendLiveMessage(val.trim());
                          Get.back();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    if (textController.text.trim().isNotEmpty) {
                      controller.sendSocketTyping(false);
                      controller.sendLiveMessage(textController.text.trim());
                      Get.back();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5252A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["🌹", "❤️", "🔥", "👏", "🎉", "😍"].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    controller.sendLiveMessage(emoji);
                    Get.back();
                  },
                  child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Detailed Settings Sheet
  void _showDetailedSettings() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Settings",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              _buildListSetting(
                "Switch Camera",
                Icons.flip_camera_ios,
                onTap: () {
                  Get.back();
                  controller.switchCamera();
                },
              ),
              Obx(
                () => _buildSwitchSetting(
                  "Mute Microphone",
                  controller.isMicMuted.value,
                  onChanged: (val) => controller.toggleMic(),
                ),
              ),
              _buildListSetting(
                "Box Battle (8 Boxes)",
                Icons.grid_view_rounded,
                onTap: () {
                  Get.back();
                  controller.startBoxBattle();
                },
              ),
              _buildListSetting(
                "Edit stream title",
                Icons.edit,
                onTap: () {
                  Get.back();
                  _showEditTitleDialog();
                },
              ),
              _buildListSetting(
                "Beauty Mode",
                Icons.face,
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    "Coming Soon",
                    "Beauty mode will be available soon!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                },
              ),
              _buildListSetting(
                "Video Quality",
                Icons.hd,
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    "Quality",
                    "Currently streaming in 720p HD.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                },
              ),
              _buildListSetting(
                "Moderator Management",
                Icons.shield_outlined,
                onTap: () {
                  Get.back();
                  controller.navigateTo("ModeratorManage");
                },
              ),
              _buildListSetting(
                "Pause live",
                Icons.pause_circle_outline,
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    "Pause live",
                    "Live stream has been paused.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text(
                "Layout",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["Panel", "6/12", "Fixed panel", "Fixed grid"].map((
                    l,
                  ) {
                    final isSelected = controller.selectedLayout.value == l;
                    return GestureDetector(
                      onTap: () => controller.setLayout(l),
                      child: _buildLayoutChip(l, isSelected: isSelected),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Comment settings",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => _buildSwitchSetting(
                  "Allow comments",
                  controller.allowComments.value,
                  onChanged: (val) => controller.toggleComments(val),
                ),
              ),
              _buildListSetting(
                "Filter comments",
                Icons.chevron_right,
                onTap: () {
                  Get.back();
                  controller.navigateTo("FilterComments");
                },
              ),
              _buildListSetting("Block keywords", Icons.chevron_right),
              Obx(
                () => _buildSwitchSetting(
                  "Mute viewers",
                  controller.isMuteViewers.value,
                  onChanged: (val) => controller.toggleMuteViewers(val),
                ),
              ),
              SizedBox(height: 24.h),
              _buildListSetting(
                "Delete stream",
                Icons.delete_outline,
                color: Colors.red,
                onTap: () {
                  Get.back();
                  _showDeleteStreamDialog();
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Invite Guests Sheet
  void _showInviteGuests() {
    controller.fetchLiveParticipants();
    final searchController = TextEditingController();
    final searchQuery = "".obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Invite Participants",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: searchController,
              onChanged: (val) => searchQuery.value = val.trim().toLowerCase(),
              decoration: InputDecoration(
                hintText: "Search viewers or enter User ID...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMembers.value) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final query = searchQuery.value;
                final allMembers = controller.liveMembers;
                final filtered = allMembers.where((m) {
                  if (query.isEmpty) return true;
                  final user = m is Map && m['user'] is Map
                      ? m['user']
                      : (m is Map ? m : {});
                  final name =
                      (user['full_name'] ??
                              user['username'] ??
                              user['name'] ??
                              '')
                          .toString()
                          .toLowerCase();
                  final username = (user['username'] ?? '')
                      .toString()
                      .toLowerCase();
                  final idStr = (user['id'] ?? (m is Map ? m['id'] : ''))
                      .toString()
                      .toLowerCase();
                  return name.contains(query) ||
                      username.contains(query) ||
                      idStr.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  final queryId = int.tryParse(query);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_disabled,
                          size: 50.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          allMembers.isEmpty
                              ? "No viewers in stream yet"
                              : "No matching viewers found",
                          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                        if (queryId != null) ...[
                          SizedBox(height: 14.h),
                          Obx(() {
                            final isInvited =
                                controller.invitedUserIds.contains(queryId) ||
                                controller.invitedUserIds.contains(
                                  queryId.toString(),
                                );
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInvited
                                    ? Colors.grey[400]
                                    : AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              icon: Icon(
                                isInvited ? Icons.check : Icons.send,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text(
                                isInvited
                                    ? "Invited User #$queryId ✓"
                                    : "Invite User #$queryId",
                                style: const TextStyle(color: Colors.white),
                              ),
                              onPressed: isInvited
                                  ? null
                                  : () => controller.inviteGuest(queryId),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    final dynamic userObj = member is Map
                        ? member['user']
                        : null;
                    final user = userObj is Map
                        ? userObj
                        : (member is Map ? member : {});
                    final name =
                        user['full_name'] ??
                        user['username'] ??
                        user['name'] ??
                        'Unknown User';
                    final username = user['username'] != null
                        ? '@${user['username']}'
                        : '';
                    final avatar = user['profile_picture'] ?? user['avatar'];
                    final userId =
                        (userObj is Map ? userObj['id'] : null) ??
                        (userObj is int || userObj is String
                            ? userObj
                            : null) ??
                        (member is Map
                            ? (member['user_id'] ?? member['id'])
                            : null);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (avatar != null && avatar.toString().isNotEmpty)
                            ? NetworkImage(avatar.toString())
                            : const AssetImage('assets/images/user_avatar.png')
                                  as ImageProvider,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(username),
                      trailing: Obx(() {
                        final isInvited =
                            controller.invitedUserIds.contains(userId) ||
                            controller.invitedUserIds.contains(
                              userId.toString(),
                            );
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInvited
                                ? Colors.grey[400]
                                : AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          onPressed: isInvited || userId == null
                              ? null
                              : () {
                                  controller.inviteGuest(userId);
                                },
                          child: Text(
                            isInvited ? "Invited ✓" : "Invite",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Live Members List Sheet
  void _showLiveMembersList() {
    controller.fetchLiveParticipants();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Live Viewers",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMembers.value) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (controller.liveMembers.isEmpty) {
                  return const Center(child: Text("No viewers yet."));
                }
                return ListView.builder(
                  itemCount: controller.liveMembers.length,
                  itemBuilder: (context, index) {
                    final member = controller.liveMembers[index];
                    final user = member is Map && member['user'] is Map
                        ? member['user']
                        : (member is Map ? member : {});
                    final name =
                        user['full_name'] ??
                        user['username'] ??
                        user['name'] ??
                        "Viewer";
                    final username = user['username'] != null
                        ? '@${user['username']}'
                        : '';
                    final avatar = user['profile_picture'] ?? user['avatar'];
                    final role =
                        (member is Map
                            ? (member['role'] ?? member['current_user_role'])
                            : null) ??
                        "Viewer";
                    final userId =
                        user['id'] ?? (member is Map ? member['id'] : null);
                    final isHost = role.toString().toLowerCase() == "host";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            (avatar != null && avatar.toString().isNotEmpty)
                            ? NetworkImage(avatar.toString())
                            : const AssetImage('assets/images/user_avatar.png')
                                  as ImageProvider,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        username.isNotEmpty ? username : role,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: isHost
                                  ? Colors.amber.withValues(alpha: 0.2)
                                  : (role.toString().toLowerCase() ==
                                            "moderator"
                                        ? Colors.blue.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              role.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: isHost
                                    ? Colors.orange[800]
                                    : (role.toString().toLowerCase() ==
                                              "moderator"
                                          ? Colors.blue[800]
                                          : Colors.grey[700]),
                              ),
                            ),
                          ),
                          if (!isHost && userId != null) ...[
                            SizedBox(width: 8.w),
                            Obx(() {
                              final isInvited =
                                  controller.invitedUserIds.contains(userId) ||
                                  controller.invitedUserIds.contains(
                                    userId.toString(),
                                  );
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInvited
                                      ? Colors.grey[400]
                                      : AppColors.primary,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  minimumSize: Size(55.w, 28.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                onPressed: isInvited
                                    ? null
                                    : () {
                                        controller.inviteGuest(userId);
                                      },
                                child: Text(
                                  isInvited ? "Invited ✓" : "Invite",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Dialogs & Helpers
  Widget _buildListSetting(
    String label,
    IconData icon, {
    VoidCallback? onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(fontSize: 14.sp, color: color),
      ),
      trailing: Icon(icon, size: 20.sp, color: color),
    );
  }

  Widget _buildSwitchSetting(
    String label,
    bool value, {
    ValueChanged<bool>? onChanged,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildLayoutChip(String label, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : AppColors.border.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: isSelected ? Border.all(color: AppColors.primary) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showEndStreamDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
              SizedBox(height: 16.h),
              Text(
                "End live stream?",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to stop streaming?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.endLiveStream();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: const Text(
                    "End live now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTitleDialog() {
    final titleController = TextEditingController(
      text: controller.liveTitle.value,
    );
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Stream Title",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter new title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        controller.liveTitle.value = titleController.text;
                        controller.updateLiveRoom({
                          'title': titleController.text,
                        });
                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Stream title updated!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteStreamDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Delete live stream?",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to permanently delete this live stream? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.deleteLiveRoom();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: const Text(
                    "Delete now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
