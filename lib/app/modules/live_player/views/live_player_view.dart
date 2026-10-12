import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glotune/app/core/utils/image_utils.dart';
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
              final liveType = controller.currentLiveType.value;

              if (liveType == 'box battle') {
                return _buildBoxBattleStreamLayout(hasRemote: hasRemote, isCohost: isCo);
              } else if (liveType == '1v1') {
                return _build1v1BattleStreamLayout(hasRemote: hasRemote, isCohost: isCo);
              } else if (liveType == '2v2') {
                return _build2v2BattleStreamLayout(hasRemote: hasRemote, isCohost: isCo);
              } else if (liveType == 'quiz') {
                return _buildQuizStreamLayout(hasRemote: hasRemote, isCohost: isCo);
              } else if (liveType == 'karaoke') {
                return _buildKaraokeStreamLayout(hasRemote: hasRemote, isCohost: isCo);
              }

              return _buildStandardLiveStreamLayout(
                hasRemote: hasRemote,
                isCohost: isCo,
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

  // MARK: - Standard Live Stream Layout
  Widget _buildStandardLiveStreamLayout({
    required bool hasRemote,
    required bool isCohost,
  }) {
    if (!hasRemote) {
      if (isCohost) {
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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

    final totalBroadcasters = controller.remoteUids.length + (isCohost ? 1 : 0);

    if (totalBroadcasters == 1) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: controller.engine,
          canvas: VideoCanvas(uid: controller.remoteUids.first),
          connection: RtcConnection(channelId: controller.roomId),
        ),
      );
    }

    final hostUid = controller.remoteUids.first;
    final otherRemoteUids = controller.remoteUids.length > 1
        ? controller.remoteUids.sublist(1)
        : <int>[];

    return Column(
      children: [
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
        Container(height: 2.h, color: Colors.white24),
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _buildPlayerParticipantsBottomHalf(
              otherRemoteUids: otherRemoteUids,
              isCohost: isCohost,
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - Box Battle Stream Layout (Viewer View)
  Widget _buildBoxBattleStreamLayout({
    required bool hasRemote,
    required bool isCohost,
  }) {
    final hostUid = hasRemote ? controller.remoteUids.first : null;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A0E0E), Color(0xFF6B1414), Color(0xFF2C0707)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 54.h),
            // Battle Score & Mode Banner
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.amberAccent, size: 16),
                      SizedBox(width: 4.w),
                      Text(
                        "BOX BATTLE",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "⏱ 01:30",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Score: 100",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            // Host + 8 Deterministic Guest Slots Arena
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    // Left: Host Stream
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: Colors.black87,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (hasRemote && hostUid != null)
                              AgoraVideoView(
                                controller: VideoViewController.remote(
                                  rtcEngine: controller.engine,
                                  canvas: VideoCanvas(uid: hostUid),
                                  connection: RtcConnection(channelId: controller.roomId),
                                ),
                              )
                            else
                              const Center(
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                                ),
                              ),
                            Positioned(
                              top: 6.h,
                              left: 6.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "HOST",
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1.w, color: Colors.white24),
                    // Right: 8 Guest Boxes (2 Col x 4 Rows)
                    Expanded(
                      flex: 5,
                      child: Obx(() {
                        final slots = controller.boxSlots;
                        return GridView.count(
                          crossAxisCount: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.95,
                          children: List.generate(8, (i) {
                            final slot = i < slots.length
                                ? slots[i]
                                : {'slot_number': i + 1, 'status': 'VACANT'};
                            return _buildViewerGuestSlotWidget(slot);
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 180.h),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerGuestSlotWidget(Map<String, dynamic> slot) {
    final status = slot['status'] ?? 'VACANT';
    final isVacant = status == 'VACANT';
    final slotNumber = slot['slot_number'] ?? 1;

    if (isVacant) {
      return GestureDetector(
        onTap: controller.requestToStream,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white12, width: 0.5),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white70, size: 16.sp),
                SizedBox(height: 2.h),
                Text(
                  "Box $slotNumber",
                  style: TextStyle(color: Colors.white54, fontSize: 8.sp),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final guestName = (slot['username'] != null && slot['username'].toString().isNotEmpty)
        ? slot['username'].toString()
        : "Guest $slotNumber";
    final pic = slot['profile_picture']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageUtils.safeNetworkImage(
            imageUrl: pic,
            fit: BoxFit.cover,
            errorWidget: const Image(
              image: AssetImage('assets/images/user_avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 2.h,
            left: 2.w,
            right: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                guestName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7.5.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - 1v1 Battle Stream Layout (Viewer View)
  Widget _build1v1BattleStreamLayout({
    required bool hasRemote,
    required bool isCohost,
  }) {
    final hostUid = hasRemote ? controller.remoteUids.first : null;
    final opponentUid = controller.remoteUids.length > 1 ? controller.remoteUids[1] : null;

    return Container(
      color: const Color(0xFF70111A),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 54.h),
            // PK Score Header Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              height: 28.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: Colors.black45,
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.orange, Colors.redAccent]),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(14.r)),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10.w),
                          child: Text(
                            "Host: 100",
                            style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(14.r)),
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 10.w),
                          child: Text(
                            "Challenger: 100",
                            style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        "⚡ PK VS ⚡",
                        style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            // Split 1v1 Arena
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  children: [
                    // Host Side
                    Expanded(
                      child: Container(
                        color: Colors.black87,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (hasRemote && hostUid != null)
                              AgoraVideoView(
                                controller: VideoViewController.remote(
                                  rtcEngine: controller.engine,
                                  canvas: VideoCanvas(uid: hostUid),
                                  connection: RtcConnection(channelId: controller.roomId),
                                ),
                              )
                            else
                              const Center(
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                                ),
                              ),
                            Positioned(
                              top: 6.h,
                              left: 6.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text("RED TEAM", style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 2.w, color: Colors.white30),
                    // Opponent Side
                    Expanded(
                      child: Container(
                        color: Colors.black87,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (opponentUid != null)
                              AgoraVideoView(
                                controller: VideoViewController.remote(
                                  rtcEngine: controller.engine,
                                  canvas: VideoCanvas(uid: opponentUid),
                                  connection: RtcConnection(channelId: controller.roomId),
                                ),
                              )
                            else
                              const Center(
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                                ),
                              ),
                            Positioned(
                              top: 6.h,
                              right: 6.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text("BLUE TEAM", style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 180.h),
          ],
        ),
      ),
    );
  }

  // MARK: - 2v2 Battle Stream Layout (Viewer View)
  Widget _build2v2BattleStreamLayout({
    required bool hasRemote,
    required bool isCohost,
  }) {
    final uids = controller.remoteUids;
    return Container(
      color: const Color(0xFF70111A),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 54.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("🔴 RED TEAM: 200", style: TextStyle(color: Colors.redAccent, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text("2v2 BATTLE", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text("🔵 BLUE TEAM: 200", style: TextStyle(color: Colors.blueAccent, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(4, (i) {
                    final uid = i < uids.length ? uids[i] : null;
                    final isRed = i % 2 == 0;
                    return Container(
                      margin: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: isRed ? Colors.redAccent : Colors.blueAccent, width: 1.5),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.black,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (uid != null)
                            AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: controller.engine,
                                canvas: VideoCanvas(uid: uid),
                                connection: RtcConnection(channelId: controller.roomId),
                              ),
                            )
                          else
                            const Center(
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage('assets/images/user_avatar.png'),
                              ),
                            ),
                          Positioned(
                            bottom: 4.h,
                            left: 4.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                "Player ${i + 1}",
                                style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 180.h),
          ],
        ),
      ),
    );
  }

  // MARK: - Live Quiz Stream Layout (Viewer View)
  Widget _buildQuizStreamLayout({
    required bool hasRemote,
    required bool isCohost,
  }) {
    final hostUid = hasRemote ? controller.remoteUids.first : null;
    return Container(
      color: const Color(0xFF6B1414),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 54.h),
            _buildQuizCategorySelectorBar(),
            SizedBox(height: 4.h),
            _buildQuizMainSection(hasRemote: hasRemote, hostUid: hostUid),
            SizedBox(height: 180.h),
          ],
        ),
      ),
    );
  }

  // MARK: - Category Selector Bar (Dynamic from API)
  Widget _buildQuizCategorySelectorBar() {
    return Obx(() {
      final categories = controller.quizCategories.toList();
      if (categories.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 34.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => SizedBox(width: 6.w),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final catId = cat['id']?.toString() ?? '';
            final catName = cat['name']?.toString() ?? '';
            final qCount = cat['question_count'];
            final isSelected = controller.selectedQuizCategoryId.value == catId ||
                controller.selectedQuizCategoryName.value == catName;

            return GestureDetector(
              onTap: () => controller.lockQuizCategory(catId, catName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? Colors.amberAccent : Colors.white24,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getQuizCategoryIcon(catName),
                      color: isSelected ? Colors.black : Colors.white70,
                      size: 12.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      catName,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 9.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (qCount != null) ...[
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black26 : Colors.white24,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "${qCount}Q",
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  IconData _getQuizCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('entertain') || lower.contains('pop') || lower.contains('culture')) {
      return Icons.theater_comedy_outlined;
    } else if (lower.contains('corporate') || lower.contains('business') || lower.contains('finance')) {
      return Icons.business_center_outlined;
    } else if (lower.contains('sport') || lower.contains('athletic')) {
      return Icons.sports_soccer_outlined;
    } else if (lower.contains('media') || lower.contains('journalism') || lower.contains('news')) {
      return Icons.newspaper_outlined;
    } else if (lower.contains('politic') || lower.contains('governance')) {
      return Icons.account_balance_outlined;
    } else if (lower.contains('science') || lower.contains('technolog')) {
      return Icons.biotech_outlined;
    }
    return Icons.quiz_outlined;
  }

  // MARK: - Main Quiz Section (Host Arena + Contestant Grid)
  Widget _buildQuizMainSection({
    required bool hasRemote,
    int? hostUid,
  }) {
    return SizedBox(
      height: 340.h,
      child: Row(
        children: [
          // Left: Host Video + Quiz Question & Choices
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Remote Host Video via Agora RTC
                if (hasRemote && hostUid != null)
                  AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: controller.engine,
                      canvas: VideoCanvas(uid: hostUid),
                      connection: RtcConnection(channelId: controller.roomId),
                    ),
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      image: DecorationImage(
                        image: AssetImage('assets/images/user_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Dark gradient overlay for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ),

                // Host Badge + Category Pill (Clickable)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Obx(() => GestureDetector(
                    onTap: _showQuizCategoryBottomSheet,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.black, size: 12),
                          SizedBox(width: 3.w),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 80.w),
                            child: Text(
                              controller.selectedQuizCategoryName.value.isNotEmpty
                                  ? "Host • ${controller.selectedQuizCategoryName.value}"
                                  : "Host • Live Quiz",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black, size: 14),
                        ],
                      ),
                    ),
                  )),
                ),

                // Authoritative 30s Countdown Timer Badge
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: controller.isQuizRoundActive.value
                          ? const Color(0xFFE50914)
                          : Colors.black87,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "VS ${controller.quizTimerText.value}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ),

                // Question Card & Options A-D
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  right: 8.w,
                  child: Obx(() {
                    final qMap = controller.quizQuestion;
                    final isRoundActive = controller.isQuizRoundActive.value;
                    final answers = controller.activeQuizAnswers.toList();

                    String qText;
                    if (qMap['question'] != null && qMap['question'].toString().isNotEmpty) {
                      qText = qMap['question'].toString();
                    } else if (isRoundActive) {
                      qText = "Loading question from server...";
                    } else if (controller.selectedQuizCategoryName.value.isNotEmpty) {
                      qText = "🎯 Category: ${controller.selectedQuizCategoryName.value}\nRound starting soon...";
                    } else {
                      qText = "Select a Category & Start Round";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Question Card
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            qText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // Options A, B, C, D from activeQuizAnswers or quizQuestion
                        if (answers.isNotEmpty)
                          ...answers.map((ans) {
                            final code = ans['option_code']?.toString() ?? 'A';
                            final text = ans['answer_text']?.toString() ?? '';
                            return Padding(
                              padding: EdgeInsets.only(bottom: 3.h),
                              child: _buildQuizViewerOption(code, text),
                            );
                          })
                        else if (qMap['options'] is List && (qMap['options'] as List).isNotEmpty)
                          ...(qMap['options'] as List).map((opt) {
                            final optStr = opt.toString();
                            String code = 'A';
                            String text = optStr;
                            if (optStr.contains('.')) {
                              final parts = optStr.split('.');
                              code = parts.first.trim();
                              text = parts.sublist(1).join('.').trim();
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 3.h),
                              child: _buildQuizViewerOption(code, text),
                            );
                          }),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          Container(width: 1.w, color: Colors.white24),

          // Right: 2-Column Participant Grid (8 Seats)
          Expanded(
            flex: 5,
            child: Obx(() {
              final participants = controller.quizParticipants.toList();
              final remoteUids = controller.remoteUids.toList();

              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(8, (index) {
                  if (index < participants.length) {
                    final p = participants[index];
                    final name = p['username']?.toString() ?? "Guest ${index + 1}";
                    final fanA = p['fan_gifts_a'] ?? 0;
                    final platB = p['platform_reward_b'] ?? 0;
                    final score = "$fanA + $platB";
                    final selectedOpt = p['selected_option']?.toString();
                    final isCorrect = p['is_correct'] == true;
                    final uid = p['user_id'] is int
                        ? p['user_id'] as int
                        : int.tryParse(p['user_id']?.toString() ?? '') ?? 0;

                    return _buildQuizParticipantSlot(
                      name: name,
                      score: score,
                      selectedOption: selectedOpt,
                      isCorrect: isCorrect,
                      userId: uid,
                    );
                  }

                  // Default connected remote co-host or vacant slot
                  if (index < remoteUids.length) {
                    final remoteUid = remoteUids[index];
                    return _buildQuizParticipantSlot(
                      name: "Guest $remoteUid",
                      score: "0 + 0",
                      userId: remoteUid,
                    );
                  }

                  return _buildQuizVacantSeatSlot(index + 1);
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  // MARK: - Option Pill Button (Viewer Interactive)
  Widget _buildQuizViewerOption(String code, String text) {
    return Obx(() {
      final selected = controller.quizSelectedOption.value;
      final isSelected = selected == code ||
          (selected != null && selected.toUpperCase().startsWith(code.toUpperCase()));
      final isScored = controller.isQuizScored.value;
      final isCorrect = controller.quizCorrectOption.value.toUpperCase() == code.toUpperCase();

      Color bgColor;
      if (code == "A") {
        bgColor = Colors.cyan;
      } else if (code == "B") {
        bgColor = Colors.purpleAccent;
      } else if (code == "C") {
        bgColor = Colors.amber;
      } else {
        bgColor = Colors.orange;
      }

      if (isScored) {
        if (isCorrect) {
          bgColor = Colors.green;
        } else if (isSelected) {
          bgColor = Colors.redAccent;
        }
      }

      return GestureDetector(
        onTap: () {
          if (!controller.isQuizAnswerSubmitted.value && controller.isQuizRoundActive.value) {
            controller.selectQuizOption(code);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10.r),
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 4)]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "$code. $text",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  isScored
                      ? (isCorrect ? Icons.check_circle : Icons.cancel)
                      : Icons.check,
                  color: Colors.white,
                  size: 11.sp,
                ),
            ],
          ),
        ),
      );
    });
  }

  // MARK: - Participant Seat Slot (Viewer View)
  Widget _buildQuizParticipantSlot({
    required String name,
    required String score,
    String? selectedOption,
    bool isCorrect = false,
    required int userId,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23252E),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Remote Video if connected, otherwise avatar
          if (controller.remoteUids.contains(userId))
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: userId),
                connection: RtcConnection(channelId: controller.roomId),
              ),
            )
          else
            Image.asset(
              'assets/images/user_avatar.png',
              fit: BoxFit.cover,
            ),

          // Top-left: a + b Reward Score
          Positioned(
            top: 2.h,
            left: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                score,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Top-right: Selected option badge or Correct/Wrong icon
          Positioned(
            top: 2.h,
            right: 2.w,
            child: Obx(() => Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: controller.isQuizScored.value
                  ? Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                      size: 11.sp,
                    )
                  : (selectedOption != null && selectedOption.isNotEmpty
                      ? CircleAvatar(
                          radius: 6.r,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            selectedOption,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.help_outline,
                          color: Colors.white54,
                          size: 10.sp,
                        )),
            )),
          ),

          // Bottom-right: Name Pill with pink '+' Gift Icon
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTap: () {
                controller.showTemporaryNotice("Send gift to $name 🎁");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    const Icon(
                      Icons.add_circle,
                      color: Colors.pinkAccent,
                      size: 8,
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

  // MARK: - Vacant Seat Slot
  Widget _buildQuizVacantSeatSlot(int seatNumber) {
    return GestureDetector(
      onTap: () => controller.requestToStream(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6B1414), width: 1.5),
            ),
            child: Icon(Icons.add, color: const Color(0xFF6B1414), size: 18.sp),
          ),
        ),
      ),
    );
  }

  // Category Selector BottomSheet
  void _showQuizCategoryBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Select Quiz Category",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final cats = controller.quizCategories.toList();
              if (cats.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: Text(
                      "No categories available",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }
              return Column(
                children: cats.map((cat) {
                  final catId = cat['id']?.toString() ?? '';
                  final catName = cat['name']?.toString() ?? '';
                  final isSel = controller.selectedQuizCategoryId.value == catId ||
                      controller.selectedQuizCategoryName.value == catName;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isSel ? Colors.amber : Colors.white12,
                      child: Icon(
                        _getQuizCategoryIcon(catName),
                        color: isSel ? Colors.black : Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    title: Text(
                      catName,
                      style: TextStyle(
                        color: isSel ? Colors.amberAccent : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: cat['description'] != null
                        ? Text(
                            cat['description'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                          )
                        : null,
                    trailing: isSel
                        ? const Icon(Icons.check_circle, color: Colors.amberAccent)
                        : null,
                    onTap: () {
                      controller.lockQuizCategory(catId, catName);
                      Get.back();
                    },
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Karaoke Stream Layout (Viewer View)
  Widget _buildKaraokeStreamLayout({
    required bool hasRemote,
    required bool isCohost,
  }) {
    final hostUid = hasRemote ? controller.remoteUids.first : null;
    return Container(
      color: const Color(0xFF6B1414),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 54.h),
            SizedBox(
              height: 340.h,
              child: Row(
                children: [
                  // Left Side: Host Video + Track Details & Synced Lyrics
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasRemote && hostUid != null)
                          AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: controller.engine,
                              canvas: VideoCanvas(uid: hostUid),
                              connection: RtcConnection(channelId: controller.roomId),
                            ),
                          )
                        else
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              image: DecorationImage(
                                image: AssetImage('assets/images/user_avatar.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Host Badge
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, color: Colors.black, size: 12),
                                SizedBox(width: 3.w),
                                Text(
                                  "Host • Karaoke",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Live Countdown Timer Badge
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Obx(() => Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: controller.isKaraokePerformanceActive.value
                                  ? const Color(0xFFE50914)
                                  : Colors.black87,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              "VS ${controller.karaokeTimerText.value}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                        ),

                        // Track Details & Real-Time Synced Lyrics
                        Positioned(
                          bottom: 8.h,
                          left: 8.w,
                          right: 8.w,
                          child: Obx(() {
                            final title = controller.karaokeTitle.value;
                            final artist = controller.karaokeArtist.value;
                            final lyrics = controller.karaokeLyrics.value;
                            final isInstrumental = controller.karaokeContentType.value == 'INSTRUMENTAL';
                            final isEligible = controller.isRewardEligible.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Floating Synced Lyrics
                                if (lyrics.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    margin: EdgeInsets.only(bottom: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: Colors.pinkAccent, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.music_note, color: Colors.pinkAccent, size: 12),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            lyrics,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Track Information Card
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: Colors.white24, width: 0.8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                            decoration: BoxDecoration(
                                              color: isInstrumental ? Colors.amber : Colors.purpleAccent,
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              isInstrumental ? "INSTRUMENTAL" : "MUSIC",
                                              style: TextStyle(color: Colors.black, fontSize: 7.sp, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (isEligible) ...[
                                            SizedBox(width: 4.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                "REWARD ELIGIBLE (b)",
                                                style: TextStyle(color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        title.isNotEmpty ? title : "Awaiting Track Selection",
                                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (artist.isNotEmpty)
                                        Text(
                                          "Artist: $artist",
                                          style: TextStyle(color: Colors.white70, fontSize: 8.5.sp),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  Container(width: 1.w, color: Colors.white24),

                  // Right Side: 8-Participant Slots Grid
                  Expanded(
                    flex: 5,
                    child: Obx(() {
                      final participants = controller.karaokeParticipants.toList();
                      final remoteUids = controller.remoteUids.toList();

                      return GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 0.95,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(8, (index) {
                          if (index < participants.length) {
                            final p = participants[index];
                            final name = p['username']?.toString() ?? "Guest ${index + 1}";
                            final fanA = p['fan_gifts_a'] ?? "0.00";
                            final platB = p['platform_reward_b'] ?? "0.00";
                            final score = "$fanA + $platB";
                            final uid = p['user_id'] is int
                                ? p['user_id'] as int
                                : int.tryParse(p['user_id']?.toString() ?? '') ?? 0;
                            final isSinger = controller.karaokeCurrentSingerId.value == uid && uid > 0;

                            return _buildViewerKaraokeSlot(
                              name: name,
                              score: score,
                              userId: uid,
                              isSinger: isSinger,
                            );
                          }

                          if (index < remoteUids.length) {
                            final remoteUid = remoteUids[index];
                            final isSinger = controller.karaokeCurrentSingerId.value == remoteUid;
                            return _buildViewerKaraokeSlot(
                              name: "Guest $remoteUid",
                              score: "0.00 + 0.00",
                              userId: remoteUid,
                              isSinger: isSinger,
                            );
                          }

                          return _buildQuizVacantSeatSlot(index + 1);
                        }),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 180.h),
          ],
        ),
      ),
    );
  }

  // MARK: - Viewer Karaoke Participant Slot
  Widget _buildViewerKaraokeSlot({
    required String name,
    required String score,
    required int userId,
    bool isSinger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23252E),
        border: Border.all(
          color: isSinger ? Colors.pinkAccent : Colors.white12,
          width: isSinger ? 1.5 : 0.5,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller.remoteUids.contains(userId))
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: userId),
                connection: RtcConnection(channelId: controller.roomId),
              ),
            )
          else
            Image.asset(
              'assets/images/user_avatar.png',
              fit: BoxFit.cover,
            ),

          // Top-left: a + b Score (Fan Gifts + Platform Reward)
          Positioned(
            top: 2.h,
            left: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                score,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 7.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Top-right: Microphone Badge if Current Singer
          if (isSinger)
            Positioned(
              top: 2.h,
              right: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: Colors.white, size: 8.sp),
                    SizedBox(width: 2.w),
                    Text("SINGER", style: TextStyle(color: Colors.white, fontSize: 6.5.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          // Bottom-right: Name with Pink Gift Icon
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTap: () {
                controller.sendKaraokeGift(
                  receiverUserId: userId,
                  amount: 100.0,
                  giftType: 'KARAOKE_MIC',
                );
                controller.showTemporaryNotice("Sent 100 Coins gift to $name 🎁");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    const Icon(Icons.add_circle, color: Colors.pinkAccent, size: 8),
                  ],
                ),
              ),
            ),
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
            () => ImageUtils.safeCircleAvatar(
              radius: 18.r,
              imageUrl: controller.hostProfilePic.value,
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
                    GestureDetector(
                      onTap: _showLiveMembersList,
                      child: Row(
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
                    ),
                    Obx(() {
                      final type = controller.currentLiveType.value;
                      if (type == 'live') return const SizedBox.shrink();
                      return Container(
                        margin: EdgeInsets.only(left: 6.w),
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
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
              final isSessionNotif = msg is Map &&
                  (msg['is_session_notification'] == true ||
                      msg['type'] == 'session_status_notification' ||
                      msg['type'] == 'session_status');
              final isSystem = msg is Map &&
                  (msg['is_system'] == true || msg['type'] == 'member_action') &&
                  !isSessionNotif;
              final text = (msg is Map
                      ? (msg['message'] ?? msg['content'] ?? msg['text'])
                      : msg.toString()) ??
                  "";

              // Special highlight for game/session join notifications
              if (isSessionNotif) {
                final pic = msg['profile_picture']?.toString();
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED).withValues(alpha: 0.85),
                            const Color(0xFFDB2777).withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageUtils.safeCircleAvatar(
                            radius: 10.r,
                            imageUrl: pic,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

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
              final pic = (msg is Map ? msg['profile_picture'] : null)?.toString() ??
                  userObj['profile_picture']?.toString();

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pic != null && pic.isNotEmpty) ...[
                      ImageUtils.safeCircleAvatar(
                        radius: 8.r,
                        imageUrl: pic,
                      ),
                      SizedBox(width: 4.w),
                    ],
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

  void _showLiveMembersList() {
    Get.bottomSheet(
      Container(
        height: 0.5.sh,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
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
              children: [
                Text(
                  "Participants & Viewers",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "${controller.memberCount.value}",
                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (controller.liveMembers.isEmpty) {
                  return Center(
                    child: Text(
                      "No participants yet",
                      style: TextStyle(color: Colors.white60, fontSize: 13.sp),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.liveMembers.length,
                  itemBuilder: (context, index) {
                    final member = controller.liveMembers[index];
                    final user = member is Map && member['user'] is Map
                        ? member['user']
                        : (member is Map ? member : {});
                    final name =
                        user['username'] ??
                        user['full_name'] ??
                        user['name'] ??
                        "Viewer";
                    final avatar = user['profile_picture'] ?? user['avatar'];
                    final gameType = member is Map ? member['game_type'] : null;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ImageUtils.safeCircleAvatar(
                        radius: 18.r,
                        imageUrl: avatar?.toString(),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                      subtitle: gameType != null
                          ? Text(
                              "in $gameType",
                              style: TextStyle(color: Colors.pinkAccent, fontSize: 11.sp),
                            )
                          : null,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Active",
                          style: TextStyle(color: Colors.greenAccent, fontSize: 10.sp),
                        ),
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
