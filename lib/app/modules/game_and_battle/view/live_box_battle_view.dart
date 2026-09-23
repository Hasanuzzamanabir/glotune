import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/modules/create/controllers/create_controller.dart';

class LiveBoxBattleView extends GetView<CreateController> {
  const LiveBoxBattleView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitBattleDialog(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A0E0E), Color(0xFF6B1414), Color(0xFF2C0707)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopHeader(context),
                _buildSubHeader(),
                SizedBox(height: 6.h),
                _buildBoxBattleMainSection(context),
                Expanded(child: _buildChatList()),
                _buildBottomActionBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Top Header
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: 10,
                        ),
                        SizedBox(width: 2.w),
                        Obx(
                          () => Text(
                            controller.liveMemberCount.value > 0
                                ? "${controller.liveMemberCount.value}"
                                : "283k",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "+ Follow",
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
          const Spacer(),
          Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 16.sp),
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Obx(
              () => Text(
                "${controller.liveMemberCount.value}",
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () {
              Get.snackbar(
                "Share",
                "Stream link copied to clipboard!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
                colorText: Colors.black,
              );
            },
            child: CircleAvatar(
              radius: 14.r,
              backgroundColor: Colors.black45,
              child: const Icon(Icons.share, color: Colors.white, size: 14),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () => _showExitBattleDialog(context),
            child: CircleAvatar(
              radius: 14.r,
              backgroundColor: Colors.black45,
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Sub Header
  Widget _buildSubHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 30.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Text(
                    "@username",
                    style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                  ),
                  const Spacer(),
                  const Icon(Icons.search, color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.cloud_upload_outlined, color: Colors.white70, size: 20.sp),
          SizedBox(width: 8.w),
          Icon(Icons.flag_outlined, color: Colors.white70, size: 20.sp),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              "⚡ GloTune #1",
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Main Box Battle Section (Host + 8 Guest Boxes)
  Widget _buildBoxBattleMainSection(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: Row(
        children: [
          // Left: Host Panel
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Live Agora Host Video Feed
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
                      color: Colors.black,
                      image: (pic != null && pic.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(pic),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                'assets/images/user_avatar.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                }),

                // Host Pill Top-Left
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12.r),
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

                // 1:30 Countdown Timer Pill Top-Right
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        controller.formattedBoxBattleTimer,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Host Bottom Pill with Mic Status
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.isMicMuted.value
                                ? Icons.mic_off
                                : Icons.mic,
                            color: controller.isMicMuted.value
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            size: 11.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "You",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1.w, color: Colors.white24),

          // Right: 8 Deterministic Guest Slots (2 Columns x 4 Rows)
          Expanded(
            flex: 5,
            child: Obx(() {
              final slots = controller.boxSlots.toList();
              return GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.95,
                children: List.generate(8, (index) {
                  final slot = index < slots.length
                      ? slots[index]
                      : <String, dynamic>{
                          'slot_number': index + 1,
                          'status': 'VACANT',
                        };
                  return _buildGuestSlotWidget(context, slot);
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  // MARK: - Individual Guest Slot Widget (Vacant or Occupied)
  Widget _buildGuestSlotWidget(
    BuildContext context,
    Map<String, dynamic> slot,
  ) {
    final status = slot['status'] ?? 'VACANT';
    final isVacant = status == 'VACANT';
    final slotNumber = slot['slot_number'] ?? 1;

    if (isVacant) {
      return GestureDetector(
        onTap: () => _showInviteGuests(context),
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
              child: Icon(
                Icons.add,
                color: const Color(0xFF6B1414),
                size: 18.sp,
              ),
            ),
          ),
        ),
      );
    }

    // Occupied Slot
    final guestName =
        (slot['username'] != null && slot['username'].toString().isNotEmpty)
        ? slot['username'].toString()
        : "Guest $slotNumber";
    final giftTotal = slot['gift_total'] ?? 0;
    final bonusTotal = slot['bonus_total'] ?? 0;
    final scoreStr = "$giftTotal + $bonusTotal";
    final uid = slot['uid'] as int?;
    final micEnabled = slot['mic_on'] != false;
    final cameraEnabled = slot['camera_on'] != false;

    return GestureDetector(
      onTap: () => _showSlotModerationSheet(context, slot),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Remote video or fallback avatar
            if (cameraEnabled &&
                controller.isLiveEngineInitialized.value &&
                controller.liveEngine != null &&
                uid != null &&
                uid > 0)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: controller.liveEngine!,
                  canvas: VideoCanvas(uid: uid),
                  connection: RtcConnection(
                    channelId: controller.liveRoomId.value,
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/user_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Top-left score pill: Gift + Bonus
            Positioned(
              top: 3.h,
              left: 3.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  scoreStr,
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Bottom-right name & mic pill
            Positioned(
              bottom: 3.h,
              right: 3.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      guestName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      micEnabled ? Icons.mic : Icons.mic_off,
                      color: micEnabled ? Colors.pinkAccent : Colors.redAccent,
                      size: 9.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Slot Moderation Sheet
  void _showSlotModerationSheet(
    BuildContext context,
    Map<String, dynamic> slot,
  ) {
    final slotNumber = slot['slot_number'] as int;
    final guestName =
        (slot['username'] != null && slot['username'].toString().isNotEmpty)
        ? slot['username'].toString()
        : "Guest $slotNumber";
    final micEnabled = slot['mic_on'] != false;
    final cameraEnabled = slot['camera_on'] != false;

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
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: const AssetImage(
                    'assets/images/user_avatar.png',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guestName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Occupying Slot #$slotNumber",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(
                micEnabled ? Icons.mic_off : Icons.mic,
                color: micEnabled ? Colors.orange : Colors.green,
              ),
              title: Text(micEnabled ? "Mute Microphone" : "Unmute Microphone"),
              onTap: () {
                Get.back();
                controller.toggleSlotMic(slotNumber);
              },
            ),
            ListTile(
              leading: Icon(
                cameraEnabled ? Icons.videocam_off : Icons.videocam,
                color: cameraEnabled ? Colors.orange : Colors.green,
              ),
              title: Text(cameraEnabled ? "Disable Camera" : "Enable Camera"),
              onTap: () {
                Get.back();
                controller.toggleSlotCamera(slotNumber);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text(
                "Remove from Box",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                controller.removeBoxGuest(slotNumber);
              },
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Chat Stream
  Widget _buildChatList() {
    return Obx(() {
      final messages = controller.liveMessages;

      // If empty, show Stream Has been Started
      if (messages.isEmpty) {
        final mockEvents = [
          {
            "user": " ",
            "text": "Stream Has been Started",
            "isAction": false,
          },
        ];

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          itemCount: mockEvents.length,
          itemBuilder: (context, index) {
            final item = mockEvents[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 9.r,
                        backgroundImage: const AssetImage(
                          'assets/images/user_avatar.png',
                        ),
                      ),
                      SizedBox(width: 6.w),
                      RichText(
                        text: TextSpan(
                          children: [
                            if ((item['user'] as String).trim().isNotEmpty)
                              TextSpan(
                                text: "${item['user']} ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                ),
                              ),
                            TextSpan(
                              text: item['text'] as String,
                              style: TextStyle(
                                color: item['isAction'] == true
                                    ? Colors.orangeAccent
                                    : Colors.white70,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final text =
              (msg is Map
                  ? (msg['message'] ?? msg['content'] ?? msg['text'])
                  : msg.toString()) ??
              "";
          final sender = (msg is Map ? (msg['username'] ?? "User") : "User");

          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 9.r,
                      backgroundImage: const AssetImage(
                        'assets/images/user_avatar.png',
                      ),
                    ),
                    SizedBox(width: 6.w),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "@$sender ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                          TextSpan(
                            text: text,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // MARK: - Bottom Action Bar (5 Required Host Controls)
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            Icons.settings_outlined,
            "Settings",
            onTap: () => _showBoxBattleSettings(context),
          ),
          _buildActionItem(
            Icons.person_add_alt_1_outlined,
            "Add Guest",
            onTap: () => _showInviteGuests(context),
          ),
          _buildActionItem(
            Icons.cached_outlined,
            "Switch Game",
            onTap: () => _showSwitchGameSheet(context),
          ),
          _buildActionItem(
            Icons.chat_bubble_outline,
            "Comments",
            onTap: () => _showCommentDialog(context),
          ),
          _buildActionItem(
            Icons.pause,
            "Pause Live",
            onTap: () {
              Get.snackbar(
                "Pause Live",
                "Live stream has been paused. Guests remain connected.",
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

  Widget _buildActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 9.sp),
          ),
        ],
      ),
    );
  }

  // MARK: - Host Box Battle Settings Sheet
  void _showBoxBattleSettings(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Box Battle Settings",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ListTile(
              leading: const Icon(Icons.flip_camera_ios),
              title: const Text("Switch Camera"),
              onTap: () {
                Get.back();
                controller.switchCamera();
              },
            ),
            Obx(
              () => ListTile(
                leading: Icon(
                  controller.isMicMuted.value ? Icons.mic_off : Icons.mic,
                  color: controller.isMicMuted.value
                      ? Colors.red
                      : Colors.green,
                ),
                title: Text(
                  controller.isMicMuted.value
                      ? "Unmute Microphone"
                      : "Mute Microphone",
                ),
                onTap: () => controller.toggleMic(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text("Video Quality"),
              subtitle: const Text("720p HD"),
              onTap: () {
                Get.back();
                Get.snackbar(
                  "Video Quality",
                  "Streaming in 720p HD",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text(
                "End Box Battle",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();
                _showExitBattleDialog(context);
              },
            ),
          ],
        ),
      ),
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
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Switch Game Mode",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ListTile(
              leading: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                "Box Battle (8 Boxes)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.sports_esports_outlined),
              title: const Text("1v1 PK Battle"),
              subtitle: const Text("Face off against another creator"),
              onTap: () {
                Get.back();
                controller.endBoxBattle();
                Get.snackbar(
                  "1v1 PK Battle",
                  "1v1 PK mode is loading...",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic_external_on_outlined),
              title: const Text("Karaoke Party"),
              subtitle: const Text("Sing together with fans"),
              onTap: () {
                Get.back();
                controller.endBoxBattle();
                Get.snackbar(
                  "Karaoke Party",
                  "Karaoke mode is loading...",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                "Exit to Normal Live",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                controller.endBoxBattle();
              },
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Comment Dialog
  void _showCommentDialog(BuildContext context) {
    final commentController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: Colors.black87,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Say something in Box Battle...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      controller.sendLiveMessage(val.trim());
                      Get.back();
                    }
                  },
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () {
                  if (commentController.text.trim().isNotEmpty) {
                    controller.sendLiveMessage(commentController.text.trim());
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Invite Guests Bottom Sheet
  void _showInviteGuests(BuildContext context) {
    controller.fetchLiveParticipants();
    final searchController = TextEditingController();
    final searchQuery = "".obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Invite to Box Battle",
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
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMembers.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rawList = controller.liveMembers;
                final query = searchQuery.value;

                final filteredList = rawList.where((m) {
                  final user = m is Map && m['user'] is Map
                      ? m['user']
                      : (m is Map ? m : {});
                  final name =
                      (user['full_name'] ??
                              user['name'] ??
                              user['username'] ??
                              "")
                          .toString()
                          .toLowerCase();
                  final idStr = (user['id'] ?? user['user_id'] ?? "")
                      .toString();
                  return name.contains(query) || idStr.contains(query);
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "No active viewers found",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = filteredList[index];
                    final user = member is Map && member['user'] is Map
                        ? member['user']
                        : (member is Map ? member : {});
                    final name =
                        user['full_name'] ??
                        user['name'] ??
                        user['username'] ??
                        "Viewer ${index + 1}";
                    final userId =
                        user['id'] ??
                        (member is Map ? member['user_id'] : null);
                    final pic =
                        user['profile_picture_url'] ?? user['profile_picture'];

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 4.h,
                      ),
                      leading: CircleAvatar(
                        radius: 20.r,
                        backgroundImage:
                            (pic != null && pic.toString().isNotEmpty)
                            ? NetworkImage(pic.toString())
                            : const AssetImage('assets/images/user_avatar.png')
                                  as ImageProvider,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                      subtitle: Text(
                        "ID: $userId",
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B1414),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: () {
                          if (userId != null) {
                            final parsedId = int.tryParse(userId.toString());
                            if (parsedId != null) {
                              controller.inviteGuest(parsedId);
                              Get.back();
                            }
                          }
                        },
                        child: Text(
                          "Invite",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
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

  // MARK: - Exit Battle Dialog
  void _showExitBattleDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("End Box Battle?"),
        content: const Text(
          "Are you sure you want to end Box Battle? You will return to normal live broadcast.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.endBoxBattle();
            },
            child: const Text(
              "End Battle",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
