import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/modules/create/controllers/create_controller.dart';
import 'package:glotune/app/modules/live_player/views/widgets/floating_reactions.dart';

class LiveBattle1v1View extends GetView<CreateController> {
  const LiveBattle1v1View({super.key});

  static const Color wineBackground = Color(0xFF70111A);
  static const Color darkPillBg = Color(0x991E0507);
  static const Color lightPeachPillBg = Color(0xFFE8D5CE);
  static const Color yellowAccent = Color(0xFFF5A623);
  static const Color purpleTeamColor = Color(0xFF3B1078);
  static const Color orangeTeamColor = Color(0xFFFF7A00);

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
          _showExitBattleDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: wineBackground,
        body: Stack(
          children: [
            SafeArea(
              bottom: true,
              top: true,
              child: Column(
                children: [
                  // Top Header (Row 1 & Row 2)
                  _buildTopHeader(context),

                  SizedBox(height: 6.h),

                  // PK Battle Score Bar (3000 vs 500)
                  _buildScoreBar(),

                  // 1v1 Battle Split Video Grid
                  _buildBattleVideoGrid(context),

                  // Comments Feed (Floating on wine background)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: _buildChatList(),
                    ),
                  ),

                  // Bottom Action Bar (Settings, Find Host, Switch Game, Comments, Quit)
                  _buildBottomActionBar(context),

                  SizedBox(height: 6.h),
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
              _buildShareButton(),

              SizedBox(width: 8.w),

              // Close Button (Prompts exit battle)
              GestureDetector(
                onTap: () => _showExitBattleDialog(context),
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
                  onTap: () => _showInviteGuests(context),
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
                        Icon(
                          Icons.search,
                          color: Colors.white54,
                          size: 16.sp,
                        ),
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
                    "PK Battle is being synced to the cloud.",
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
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 9.sp,
                  ),
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

  // MARK: - Overlapping Viewers Avatar Stack
  Widget _buildViewersStack() {
    return Obx(() {
      final count = controller.liveMemberCount.value;

      final viewerImages = <String>[];
      for (final member in controller.liveMembers) {
        if (member is Map) {
          final user = member['user'] is Map ? member['user'] : member;
          final pic = user['profile_picture'] ??
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

      // If no image from socket/API, remove image views completely
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

      // If there are real viewer images, show them overlapping
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

  // MARK: - Share Button with 349 Badge
  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          "Share",
          "Battle link copied to clipboard!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34.w,
            height: 34.h,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.reply, color: Colors.white, size: 18),
          ),
          Positioned(
            bottom: -3.h,
            right: -3.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "349",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - PK Battle Score Bar (Dynamic Reactive Flex)
  Widget _buildScoreBar() {
    return Obx(() {
      final hostScore = controller.hostBattleScore.value;
      final oppScore = controller.opponentBattleScore.value;
      final total = hostScore + oppScore;
      final hostFlex = total == 0 ? 50 : ((hostScore / total) * 100).clamp(15, 85).toInt();
      final oppFlex = 100 - hostFlex;

      return SizedBox(
        height: 24.h,
        child: Row(
          children: [
            // Purple section (Host Score)
            Expanded(
              flex: hostFlex,
              child: GestureDetector(
                onTap: () => controller.sendBattleScore(10, action: 'tap'),
                child: Container(
                  color: purpleTeamColor,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 14.w),
                  child: Text(
                    "$hostScore",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Orange section (Challenger Score)
            Expanded(
              flex: oppFlex,
              child: Container(
                color: orangeTeamColor,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 14.w),
                child: Text(
                  "$oppScore",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // MARK: - 1v1 Battle Video Grid (Host Left, Challenger Right)
  Widget _buildBattleVideoGrid(BuildContext context) {
    return SizedBox(
      height: 330.h,
      child: Stack(
        children: [
          Row(
            children: [
              // Left: Host Panel (Real Host camera / user)
              Expanded(
                child: Obx(() {
                  final user = controller.userProfile.value;
                  final hostName = (user?.fullName != null &&
                          user!.fullName!.isNotEmpty)
                      ? user.fullName!
                      : (controller.liveTitle.value.isNotEmpty
                          ? controller.liveTitle.value
                          : "Host");
                  return _buildHostPanel(
                    name: "$hostName 🔥",
                    score: "${controller.hostBattleScore.value}",
                  );
                }),
              ),

              // Vertical divider line
              Container(width: 1.w, color: Colors.black87),

              // Right: Challenger Panel (Agora video if connected, or + Add Option if no one)
              Expanded(
                child: Obx(() {
                  final hasOpponent = controller.remoteUids.isNotEmpty ||
                      controller.opponentUserId.value != null;
                  if (!hasOpponent) {
                    return _buildEmptyOpponentSlot(context);
                  }

                  // Remote challenger connected
                  final remoteUid = controller.remoteUids.isNotEmpty
                      ? controller.remoteUids.first
                      : null;
                  return _buildRemoteOpponentPanel(remoteUid);
                }),
              ),
            ],
          ),

          // Red Countdown Timer Badge (Top Center-Left)
          Positioned(
            top: 10.h,
            left: (MediaQuery.of(context).size.width / 2) - 62.w,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                controller.battleTimerText.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  // MARK: - Empty Opponent Slot with + Add Icon (When no one is in 1v1)
  Widget _buildEmptyOpponentSlot(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Center Add Option with + icon
          Center(
            child: GestureDetector(
              onTap: () => _showInviteGuests(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Add Opponent",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Tap to invite to 1v1",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom waiting status pill
          Positioned(
            bottom: 10.h,
            left: 10.w,
            right: 10.w,
            child: GestureDetector(
              onTap: () => _showInviteGuests(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      color: yellowAccent,
                      size: 13.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Invite Streamer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Host Panel
  Widget _buildHostPanel({
    required String name,
    required String score,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera / Agora View / User photo fallback
        Obx(() {
          if (controller.isLiveEngineInitialized.value &&
              controller.liveEngine != null) {
            return AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: controller.liveEngine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            );
          }

          final pic = controller.userProfile.value?.profilePictureUrl;
          return Container(
            decoration: BoxDecoration(
              color: Colors.black87,
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
          );
        }),

        // Bottom gradient for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 90.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),

        // Bottom Content (Name Tag + Star Score + Ranking Gifters)
        Positioned(
          bottom: 8.h,
          left: 8.w,
          right: 8.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Capsule
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.add_circle,
                      color: yellowAccent,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6.h),

              // Star Score Pill & Ranking Avatar Badges
              Row(
                children: [
                  // Star Score Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: yellowAccent, size: 12.sp),
                        SizedBox(width: 3.w),
                        Text(
                          score,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 6.w),

                  // Top 3 Ranking Avatar Badges (3, 2, 1)
                  _buildRankingSupporterBadges(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Remote Opponent Panel (When connected or matched)
  Widget _buildRemoteOpponentPanel(int? remoteUid) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (remoteUid != null && controller.liveEngine != null)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: controller.liveEngine!,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(
                channelId: controller.liveRoomId.value,
              ),
            ),
          )
        else
          Obx(() {
            final avatar = controller.opponentAvatar.value;
            return Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36.r,
                      backgroundColor: Colors.white24,
                      backgroundImage: avatar.isNotEmpty
                          ? NetworkImage(avatar)
                          : const AssetImage('assets/images/user_avatar.png')
                              as ImageProvider,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      controller.opponentName.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Matched 🥊",
                      style: TextStyle(
                        color: yellowAccent,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

        // Bottom gradient for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 90.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),

        // Bottom Content (Opponent Name Tag + Star Score + Ranking Gifters)
        Positioned(
          bottom: 8.h,
          left: 8.w,
          right: 8.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opponent Name Capsule
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.opponentName.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.add_circle,
                      color: yellowAccent,
                      size: 16.sp,
                    ),
                  ],
                ),
              )),

              SizedBox(height: 6.h),

              // Star Score Pill & Ranking Avatar Badges
              Row(
                children: [
                  Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: yellowAccent, size: 12.sp),
                        SizedBox(width: 3.w),
                        Text(
                          "${controller.opponentBattleScore.value}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),

                  SizedBox(width: 6.w),

                  _buildRankingSupporterBadges(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Ranking Badges
  Widget _buildRankingSupporterBadges() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ["3", "2", "1"].map((rank) {
        return Padding(
          padding: EdgeInsets.only(right: 3.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 10.r,
                backgroundColor: Colors.grey[800],
                backgroundImage: const AssetImage('assets/images/user_avatar.png'),
              ),
              Positioned(
                bottom: -2.h,
                right: -2.w,
                child: Container(
                  padding: EdgeInsets.all(1.5.r),
                  decoration: BoxDecoration(
                    color: rank == "1"
                        ? Colors.amber[700]
                        : (rank == "2" ? Colors.grey[700] : Colors.brown[600]),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    rank,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 6.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // MARK: - Comments List Section (Matching Screenshot)
  Widget _buildChatList() {
    return Obx(() {
      final messages = controller.liveMessages;

      // If empty, show Stream Has been Started
      if (messages.isEmpty) {
        final chatEvents = [
          {
            "user": " ",
            "text": "Stream Has been Started",
            "type": "rose",
            "avatar": " ",
          },
        ];

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 4.h),
          itemCount: chatEvents.length,
          itemBuilder: (context, index) {
            final item = chatEvents[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: _buildCommentPill(
                username: item['user']!,
                message: item['text']!,
                type: item['type']!,
                avatarUrl: item['avatar'],
              ),
            );
          },
        );
      }

      // Dynamic socket messages
      return ListView.builder(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 4.h),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final text = (msg is Map
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
                  ? "dark"
                  : (index % 3 == 0 ? "peach" : "white"),
              avatarUrl: avatar?.toString(),
            ),
          );
        },
      );
    });
  }

  // MARK: - Comment Pill Factory
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
      case "white":
        bgColor = Colors.white.withValues(alpha: 0.95);
        userColor = Colors.black;
        textColor = Colors.black87;
        break;
      case "peach":
        bgColor = lightPeachPillBg.withValues(alpha: 0.95);
        userColor = Colors.black;
        textColor = Colors.black87;
        break;
      case "dark":
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
              backgroundImage: (avatarUrl != null && avatarUrl.trim().isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/images/user_avatar.png')
                      as ImageProvider,
            ),
            SizedBox(width: 6.w),
            RichText(
              text: TextSpan(
                children: [
                  if (username.trim().isNotEmpty)
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

  // MARK: - Bottom Action Bar (Settings, Find Host, Gifts, Comments, Quit)
  Widget _buildBottomActionBar(BuildContext context) {
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
          _buildActionItem(
            Icons.hexagon_outlined,
            "Settings",
            onTap: () => _show1v1Settings(context),
          ),

          // Find Host
          _buildActionItem(
            Icons.person_add_alt_1_outlined,
            "Find Host",
            onTap: () => _showInviteGuests(context),
          ),

          // Gifts
          _buildActionItem(
            Icons.card_giftcard_rounded,
            "Gifts",
            onTap: () => _showGiftSheet(context),
          ),

          // Comments
          _buildActionItem(
            Icons.chat_bubble_outline_rounded,
            "Comments",
            onTap: () => _showCommentInputDialog(context),
          ),

          // Quit
          _buildActionItem(
            Icons.block,
            "Quit",
            onTap: () => _showExitBattleDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24.h,
            child: Center(
              child: Icon(icon, color: Colors.white, size: 22.sp),
            ),
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

  // MARK: - Comment Input Dialog
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
                        hintText: "Cheer for your champion...",
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
              children: ["🌹", "❤️", "🔥", "👏", "🎉", "🌌"].map((emoji) {
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

  // MARK: - Battle Gift Sheet (Integrated with Live Games API)
  void _showGiftSheet(BuildContext context) {
    final selectedGift = 'rose'.obs;
    final selectedQuantity = 1.obs;
    final toOpponent = false.obs;

    final gifts = [
      {'id': 'rose', 'name': 'Rose', 'icon': '🌹', 'cost': 10},
      {'id': 'heart', 'name': 'Heart', 'icon': '❤️', 'cost': 5},
      {'id': 'galaxy', 'name': 'Galaxy', 'icon': '🌌', 'cost': 25},
      {'id': 'diamond', 'name': 'Diamond', 'icon': '💎', 'cost': 50},
      {'id': 'crown', 'name': 'Crown', 'icon': '👑', 'cost': 100},
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Send Battle Gift",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  final coins = controller.userProfile.value?.yourCoins ?? "0";
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                        SizedBox(width: 4.w),
                        Text(
                          "$coins coins",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            SizedBox(height: 14.h),

            // Target recipient toggle: Host vs Opponent
            Obx(() {
              final hasOpponent = controller.opponentUserId.value != null ||
                  controller.remoteUids.isNotEmpty;
              return Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => toOpponent.value = false,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: !toOpponent.value ? purpleTeamColor : Colors.white10,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Support Host 🔥",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (hasOpponent) ...[
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => toOpponent.value = true,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: toOpponent.value ? orangeTeamColor : Colors.white10,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Gift Challenger 🥊",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),

            SizedBox(height: 16.h),

            // Gift Cards Row
            SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gifts.length,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (context, i) {
                  final g = gifts[i];
                  return Obx(() {
                    final isSelected = selectedGift.value == g['id'];
                    return GestureDetector(
                      onTap: () => selectedGift.value = g['id'] as String,
                      child: Container(
                        width: 76.w,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected ? yellowAccent : Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(g['icon'] as String, style: TextStyle(fontSize: 26.sp)),
                            SizedBox(height: 4.h),
                            Text(
                              g['name'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${g['cost']} 🪙",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Quantity selector and Send button
            Row(
              children: [
                ...[1, 5, 10, 50].map((qty) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Obx(() {
                      final isSel = selectedQuantity.value == qty;
                      return GestureDetector(
                        onTap: () => selectedQuantity.value = qty,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isSel ? yellowAccent : Colors.white12,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "x$qty",
                            style: TextStyle(
                              color: isSel ? Colors.black : Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5252A),
                    padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    controller.sendBattleGift(
                      giftType: selectedGift.value,
                      quantity: selectedQuantity.value,
                      toOpponent: toOpponent.value,
                    );
                  },
                  child: Text(
                    "Send Gift",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Switch Game Sheet
  void _showSwitchGameSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Switch Battle Mode",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: const Text("Standard Live Stream"),
              subtitle: const Text("Return to regular single-host stream"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveStream");
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded, color: Colors.deepOrange),
              title: const Text("Box Battle (8 Boxes)"),
              subtitle: const Text("Multi-guest battle with live timer and bonus points"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                controller.startBoxBattle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.purple),
              title: const Text("Live Quiz"),
              subtitle: const Text("Trivia questions with viewers and guests"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveQuiz");
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text("2v2 Team Battle"),
              subtitle: const Text("Two teams battle for victory"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveBattle2v2");
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.pink),
              title: const Text("Karaoke Mode"),
              subtitle: const Text("Sing together with song lyrics overlay"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveKaraoke");
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // MARK: - 1v1 Settings Sheet
  void _show1v1Settings(BuildContext context) {
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
                "Battle Settings",
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
                "Moderator Management",
                Icons.shield_outlined,
                onTap: () {
                  Get.back();
                  controller.navigateTo("ModeratorManage");
                },
              ),
              _buildListSetting(
                "Switch Battle Mode",
                Icons.sync,
                onTap: () {
                  Get.back();
                  _showSwitchGameSheet(context);
                },
              ),
              Obx(
                () => _buildSwitchSetting(
                  "Allow comments",
                  controller.allowComments.value,
                  onChanged: (val) => controller.toggleComments(val),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Invite / Find Host Sheet (Auto Matchmaking & Direct Challenge)
  void _showInviteGuests(BuildContext context) {
    controller.fetchLiveParticipants();
    final searchController = TextEditingController();
    final searchQuery = "".obs;
    final selectedTab = 0.obs; // 0: Auto Matchmaking, 1: Challenge Streamers
    final searchedUsers = <Map<String, dynamic>>[].obs;
    final isSearchingUsers = false.obs;

    void performUserSearch(String query) async {
      if (query.trim().isEmpty) {
        searchedUsers.clear();
        return;
      }
      isSearchingUsers.value = true;
      try {
        final res = await controller.gameService.searchUsers(query.trim());
        searchedUsers.value = res;
      } catch (_) {
      } finally {
        isSearchingUsers.value = false;
      }
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Find / Challenge Host",
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
            SizedBox(height: 12.h),

            // Tabs: Auto Matchmaking vs Direct Challenge
            Obx(() => Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedTab.value = 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: selectedTab.value == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: selectedTab.value == 0
                              ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Auto Matchmaking ⚡",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: selectedTab.value == 0 ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedTab.value = 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: selectedTab.value == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: selectedTab.value == 1
                              ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Challenge Streamers 🥊",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: selectedTab.value == 1 ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),

            SizedBox(height: 16.h),

            // Tab Body
            Expanded(
              child: Obx(() {
                if (selectedTab.value == 0) {
                  // Tab 0: Auto Matchmaking Queue
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.isMatchmaking.value) ...[
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withValues(alpha: 0.1),
                            border: Border.all(color: const Color(0xFFE50914), width: 2),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFE50914),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Searching for 1v1 battle host...",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Queue time: ${controller.matchmakingDurationSeconds.value}s",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                          ),
                          onPressed: () {
                            controller.cancelFindHostMatchmaking();
                          },
                          child: const Text("Cancel Search", style: TextStyle(color: Colors.red)),
                        ),
                      ] else ...[
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF70111A).withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.sports_kabaddi,
                            size: 42.sp,
                            color: const Color(0xFF70111A),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Find a Matchmaking Host",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            "Automatically queue with another active streamer for a 3-minute 1v1 battle.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.bolt, color: Colors.white),
                          label: const Text(
                            "Find Opponent Now",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                          ),
                          onPressed: () {
                            controller.startFindHostMatchmaking();
                          },
                        ),
                      ],
                    ],
                  );
                }

                // Tab 1: Challenge Specific Streamers / Users
                return Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (val) {
                        searchQuery.value = val.trim().toLowerCase();
                        performUserSearch(val);
                      },
                      decoration: InputDecoration(
                        hintText: "Search streamers, friends, or username...",
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
                    SizedBox(height: 12.h),
                    Expanded(
                      child: Obx(() {
                        if (isSearchingUsers.value || controller.isLoadingMembers.value) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        // Use API searched users if available, otherwise live members
                        List candidates = searchedUsers.isNotEmpty
                            ? searchedUsers
                            : controller.liveMembers;

                        if (candidates.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_search,
                                  size: 48.sp,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "No streamers found to challenge",
                                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final item = candidates[index];
                            final dynamic userObj =
                                item is Map ? (item['user'] ?? item) : null;
                            final user = userObj is Map ? userObj : (item is Map ? item : {});
                            final name = user['full_name'] ??
                                user['username'] ??
                                user['name'] ??
                                'Streamer';
                            final username = user['username'] != null
                                ? '@${user['username']}'
                                : '';
                            final avatar = user['profile_picture'] ?? user['avatar'];
                            final userId = user['id'] ??
                                (item is Map ? (item['user_id'] ?? item['id']) : null);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: (avatar != null &&
                                        avatar.toString().isNotEmpty)
                                    ? NetworkImage(avatar.toString())
                                    : const AssetImage('assets/images/user_avatar.png')
                                        as ImageProvider,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(username),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE50914),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                                onPressed: userId == null
                                    ? null
                                    : () {
                                        Get.back();
                                        controller.inviteUserToBattle(
                                          userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
                                          name,
                                          userAvatar: avatar?.toString(),
                                        );
                                      },
                                child: const Text(
                                  "Challenge 🥊",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
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
                    final name = user['full_name'] ??
                        user['username'] ??
                        user['name'] ??
                        "Viewer";
                    final username = user['username'] != null
                        ? '@${user['username']}'
                        : '';
                    final avatar = user['profile_picture'] ?? user['avatar'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (avatar != null &&
                                avatar.toString().isNotEmpty)
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
                        username.isNotEmpty ? username : "Viewer",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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

  // MARK: - Exit Battle Dialog
  void _showExitBattleDialog(BuildContext context) {
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
                child: const Icon(Icons.block, color: Colors.white, size: 30),
              ),
              SizedBox(height: 16.h),
              Text(
                "Quit 1v1 Battle?",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to end this 1v1 battle and return to live stream?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.quitBattleMatch();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: const Text(
                    "Quit Battle",
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

  // MARK: - Helpers
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
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
