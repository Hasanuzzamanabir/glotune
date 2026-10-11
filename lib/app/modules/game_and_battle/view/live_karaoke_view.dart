import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:glotune/app/core/utils/image_utils.dart';
import 'package:glotune/app/modules/create/controllers/create_controller.dart';

class LiveKaraokeView extends GetView<CreateController> {
  const LiveKaraokeView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.joinSession("karaoke");
      controller.initOrJoinKaraokeGame();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF6B1414),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            SizedBox(height: 6.h),
            _buildKaraokeMainSection(context),
            Expanded(child: _buildChatList()),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  // MARK: - Top Header
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              // Host Profile Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Obx(() {
                      final pic = controller.userProfile.value?.profilePictureUrl;
                      return ImageUtils.safeCircleAvatar(
                        radius: 14.r,
                        imageUrl: pic,
                      );
                    }),
                    SizedBox(width: 6.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final user = controller.userProfile.value;
                          final name = (user?.fullName != null && user!.fullName!.isNotEmpty)
                              ? user.fullName!
                              : (controller.liveTitle.value.isNotEmpty
                                  ? controller.liveTitle.value
                                  : "Host");
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
                            const Icon(Icons.favorite, color: Colors.pinkAccent, size: 10),
                            SizedBox(width: 2.w),
                            Obx(
                              () => Text(
                                controller.liveMemberCount.value > 0
                                    ? "${controller.liveMemberCount.value}"
                                    : "Live",
                                style: TextStyle(color: Colors.white70, fontSize: 9.sp),
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

              // Viewers Count
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "${controller.liveMemberCount.value}",
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),

              SizedBox(width: 8.w),

              // Track Catalog Quick Pill Button
              GestureDetector(
                onTap: () => _showTrackCatalogSheet(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF007A), Color(0xFF7928CA)],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.queue_music, color: Colors.white, size: 13.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "Catalog",
                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // End Karaoke Game Button
              GestureDetector(
                onTap: () => _showEndKaraokeDialog(context),
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.black45,
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Sub-header Row
          Row(
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
                        "🎵 Karaoke Party Arena",
                        style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                      ),
                      const Spacer(),
                      Obx(() => Text(
                        controller.karaokeGameStatus.value,
                        style: TextStyle(color: Colors.amberAccent, fontSize: 9.sp, fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.8),
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
        ],
      ),
    );
  }

  // MARK: - Karaoke Main Split-Screen Section
  Widget _buildKaraokeMainSection(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: Row(
        children: [
          // Left: Host Video + Karaoke Track & Lyrics Details
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real Host Camera via Agora RTC
                Obx(() {
                  if (controller.isLiveEngineInitialized.value && controller.liveEngine != null) {
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
                      image: DecorationImage(
                        image: ImageUtils.safeImageProvider(pic),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),

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

                // Live Timer Badge (Authoritative server countdown)
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

                // Track Info & Timed Lyrics Card
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  right: 8.w,
                  child: Obx(() {
                    final title = controller.karaokeCurrentTrackTitle.value;
                    final artist = controller.karaokeCurrentTrackArtist.value;
                    final singer = controller.karaokeCurrentSinger.value;
                    final lyric = controller.karaokeCurrentLyricText.value;
                    final isInstrumental = controller.karaokeCurrentTrackType.value == 'INSTRUMENTAL';
                    final isEligible = controller.karaokeIsRewardEligible.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Live Timed Lyrics Floating Card
                        if (lyric.isNotEmpty) ...[
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
                                    lyric,
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
                        ],

                        // Track Card
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
                                title.isNotEmpty ? title : "Select Track from Catalog",
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Artist: ${artist.isNotEmpty ? artist : '—'} • Singer: @${singer.isNotEmpty ? singer : 'None'}",
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

          // Right: 2-Column Participant Grid (8 Seats)
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
                    final isCurrentSinger = controller.karaokeCurrentSingerId.value == uid && uid > 0;

                    return _buildParticipantSlot(
                      context,
                      name: name,
                      score: score,
                      userId: uid,
                      seat: "${index + 1}",
                      isSinger: isCurrentSinger,
                    );
                  }

                  if (index < remoteUids.length) {
                    final remoteUid = remoteUids[index];
                    final isCurrentSinger = controller.karaokeCurrentSingerId.value == remoteUid;
                    return _buildParticipantSlot(
                      context,
                      name: "Guest $remoteUid",
                      score: "0.00 + 0.00",
                      userId: remoteUid,
                      seat: "${index + 1}",
                      isSinger: isCurrentSinger,
                    );
                  }

                  return _buildAddParticipantSlot(context, index + 1);
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  // MARK: - Participant Seat Slot
  Widget _buildParticipantSlot(
    BuildContext context, {
    required String name,
    required String score,
    required int userId,
    required String seat,
    bool isSinger = false,
  }) {
    return GestureDetector(
      onTap: () => _showSeatOptionsSheet(context, userId: userId, name: name, seat: seat),
      child: Container(
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
            // Remote Video or Avatar
            if (controller.isLiveEngineInitialized.value &&
                controller.liveEngine != null &&
                controller.remoteUids.contains(userId))
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: controller.liveEngine!,
                  canvas: VideoCanvas(uid: userId),
                  connection: RtcConnection(channelId: controller.liveRoomId.value),
                ),
              )
            else
              Image.asset(
                'assets/images/user_avatar.png',
                fit: BoxFit.cover,
              ),

            // Top-left: a + b Reward Score (Fan Gifts a + Platform Reward b)
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

            // Bottom-right: Name Pill with Gift Icon
            Positioned(
              bottom: 2.h,
              right: 2.w,
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
          ],
        ),
      ),
    );
  }

  // MARK: - Add / Vacant Participant Slot
  Widget _buildAddParticipantSlot(BuildContext context, int seatNumber) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          "Vacant Seat #$seatNumber",
          "Guests can join or host can assign a singer to this seat.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      },
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

  // MARK: - Seat Options Sheet
  void _showSeatOptionsSheet(
    BuildContext context, {
    required int userId,
    required String name,
    required String seat,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ),
            SizedBox(height: 12.h),
            Text("@$name (Seat $seat)", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.pinkAccent),
              title: const Text("Assign as Next Singer", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Grants singing turn for next song", style: TextStyle(color: Colors.white54, fontSize: 11)),
              onTap: () {
                Get.back();
                controller.assignKaraokeSinger(userId, seat);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.amberAccent),
              title: const Text("Send Fan Gift (a)", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Send coins credited to fan gifts", style: TextStyle(color: Colors.white54, fontSize: 11)),
              onTap: () {
                Get.back();
                _showSendGiftDialog(context, userId, name);
              },
            ),
            if (controller.karaokeCurrentSingerId.value == userId)
              ListTile(
                leading: const Icon(Icons.stop_circle, color: Colors.redAccent),
                title: const Text("Remove / Stop Singer", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Get.back();
                  controller.removeKaraokeSinger();
                },
              ),
          ],
        ),
      ),
    );
  }

  // MARK: - Track Catalog Sheet
  void _showTrackCatalogSheet(BuildContext context) {
    controller.fetchKaraokeCatalog();

    Get.bottomSheet(
      Container(
        height: 0.7.sh,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.queue_music, color: Colors.pinkAccent, size: 20.sp),
                SizedBox(width: 8.w),
                Text("Karaoke Track Catalog", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Search Input
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search title or artist...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
              onSubmitted: (q) => controller.fetchKaraokeCatalog(query: q),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (controller.isKaraokeCatalogLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                }
                final catalog = controller.karaokeCatalog;
                if (catalog.isEmpty) {
                  return const Center(child: Text("No tracks found", style: TextStyle(color: Colors.white70)));
                }

                return ListView.separated(
                  itemCount: catalog.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white12, height: 1.h),
                  itemBuilder: (context, idx) {
                    final track = catalog[idx];
                    final tId = track['id']?.toString() ?? '';
                    final title = track['title']?.toString() ?? 'Track';
                    final artist = track['artist']?.toString() ?? 'Artist';
                    final type = track['content_type']?.toString() ?? 'INSTRUMENTAL';
                    final isInstrumental = type == 'INSTRUMENTAL';
                    final durMs = track['duration_ms'] ?? 180000;
                    final durSec = durMs is int ? durMs ~/ 1000 : 180;
                    final durStr = '${durSec ~/ 60}:${(durSec % 60).toString().padLeft(2, '0')}';

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      leading: CircleAvatar(
                        backgroundColor: isInstrumental ? Colors.amber.withValues(alpha: 0.2) : Colors.purple.withValues(alpha: 0.2),
                        child: Icon(
                          isInstrumental ? Icons.piano : Icons.mic,
                          color: isInstrumental ? Colors.amber : Colors.purpleAccent,
                        ),
                      ),
                      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Text("$artist • $durStr", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: isInstrumental ? Colors.amber : Colors.purpleAccent,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              isInstrumental ? "INSTRUMENTAL (b)" : "MUSIC",
                              style: TextStyle(color: Colors.black, fontSize: 7.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        ),
                        onPressed: () async {
                          Get.back();
                          await controller.selectKaraokeTrack(tId, type);
                          await controller.prepareKaraokePlayback();
                        },
                        child: const Text("Select", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // MARK: - Send Gift Dialog
  void _showSendGiftDialog(BuildContext context, int receiverUserId, String name) {
    final amounts = [100.0, 500.0, 1000.0];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: const Color(0xFF1E293B),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Send Gift to @$name 🎁", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              const Text("Gifts count toward the 1,000 Fan Gift platform threshold (a)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11)),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: amounts.map((amt) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      Get.back();
                      controller.sendKaraokeGift(
                        receiverUserId: receiverUserId,
                        amount: amt,
                        giftType: 'KARAOKE_MIC',
                      );
                    },
                    child: Text("${amt.toInt()} Coins", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - End Karaoke Dialog
  void _showEndKaraokeDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: const Color(0xFF1E293B),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("End Karaoke Session?", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              const Text("Ending the game triggers settlement of held platform rewards (b) based on the 1000 fan gifts threshold.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                      onPressed: () {
                        Get.back();
                        controller.endKaraokeGame();
                      },
                      child: const Text("End Game", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // MARK: - Chat Stream
  Widget _buildChatList() {
    return Obx(() {
      final messages = controller.liveMessages;

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final text = (msg is Map ? (msg['message'] ?? msg['content'] ?? msg['text']) : msg.toString()) ?? "";
          final userObj = msg is Map ? (msg['user'] is Map ? msg['user'] : msg) : {};
          final username = userObj['username'] ?? userObj['full_name'] ?? "Viewer";
          final avatar = (msg is Map ? msg['profile_picture'] : null) ?? userObj['profile_picture'] ?? userObj['avatar'];

          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageUtils.safeCircleAvatar(
                      radius: 9.r,
                      imageUrl: avatar?.toString(),
                    ),
                    SizedBox(width: 6.w),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "@$username ",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.sp),
                          ),
                          TextSpan(
                            text: text,
                            style: TextStyle(color: Colors.white70, fontSize: 10.sp),
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

  // MARK: - Bottom Action Bar
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(Icons.queue_music, "Catalog", onTap: () => _showTrackCatalogSheet(context)),
          Obx(() {
            final isActive = controller.isKaraokePerformanceActive.value;
            if (isActive) {
              return _buildActionItem(
                Icons.check_circle,
                "Complete",
                onTap: () => controller.completeKaraokePerformance(),
              );
            }
            return _buildActionItem(
              Icons.play_arrow,
              "Start Sing",
              onTap: () => controller.startKaraokePerformance(),
            );
          }),
          _buildActionItem(Icons.stop_circle_outlined, "Stop Singer", onTap: () => controller.removeKaraokeSinger()),
          _buildActionItem(
            Icons.cached_outlined,
            "Switch Game",
            onTap: () => controller.navigateTo("Camera"),
          ),
          _buildActionItem(Icons.exit_to_app, "End Game", onTap: () => _showEndKaraokeDialog(context)),
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
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(height: 3.h),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 8.5.sp)),
        ],
      ),
    );
  }
}
