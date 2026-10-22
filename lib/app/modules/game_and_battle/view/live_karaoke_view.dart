import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:glotune/app/core/utils/image_utils.dart';
import 'package:glotune/app/modules/create/controllers/create_controller.dart';
import 'package:glotune/app/widgets/gift_gallery_sheet.dart';

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
            _buildHostSingerControlBar(context),
            SizedBox(height: 4.h),
            _buildKaraokeMainSection(context),
            _buildFloatingKaraokeLyricsBanner(context),
            Expanded(child: _buildChatList()),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  // MARK: - Host Singer & Track Control Bar
  Widget _buildHostSingerControlBar(BuildContext context) {
    return Obx(() {
      final singer = controller.karaokeCurrentSinger.value;
      final title = controller.karaokeCurrentTrackTitle.value;
      final artist = controller.karaokeCurrentTrackArtist.value;
      final isActive = controller.isKaraokePerformanceActive.value;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: singer.isNotEmpty ? Colors.pinkAccent.withValues(alpha: 0.8) : Colors.amber.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (singer.isNotEmpty ? Colors.pinkAccent : Colors.amber).withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: singer.isNotEmpty ? Colors.pinkAccent.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                singer.isNotEmpty ? Icons.mic : Icons.person_add_alt_1,
                color: singer.isNotEmpty ? Colors.pinkAccent : Colors.amber,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          singer.isNotEmpty ? "🎤 Singer: @$singer" : "Select a Participant to Sing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (singer.isNotEmpty && title.isEmpty) ...[
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "Choosing Song",
                            style: TextStyle(color: Colors.black, fontSize: 7.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title.isNotEmpty
                        ? "🎵 $title • 👤 ${artist.isNotEmpty ? artist : 'Unknown Artist'}"
                        : (singer.isNotEmpty
                            ? "Waiting for @$singer to select a song..."
                            : "Tap to assign any guest/viewer as singer"),
                    style: TextStyle(
                      color: title.isNotEmpty ? Colors.cyanAccent : Colors.white60,
                      fontSize: 9.5.sp,
                      fontWeight: title.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Actions
            if (title.isNotEmpty && !isActive)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => controller.startKaraokePerformance(),
                child: Text("▶ Start", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
              )
            else if (isActive)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => controller.completeKaraokePerformance(),
                child: Text("⏹ Stop", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: singer.isEmpty ? Colors.pinkAccent : Colors.white24,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => _showSelectSingerSheet(context),
                child: Text(
                  singer.isEmpty ? "Select Singer" : "Change",
                  style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      );
    });
  }

  // MARK: - Floating Karaoke Lyrics Banner
  Widget _buildFloatingKaraokeLyricsBanner(BuildContext context) {
    return Obx(() {
      final lyric = controller.karaokeCurrentLyricText.value;
      final nextLyric = controller.karaokeNextLyricText.value;
      final isActive = controller.isKaraokePerformanceActive.value;
      final title = controller.karaokeCurrentTrackTitle.value;
      final artist = controller.karaokeCurrentTrackArtist.value;
      final singer = controller.karaokeCurrentSinger.value;

      String displayLyric = lyric;
      if (displayLyric.isEmpty) {
        if (title.isNotEmpty) {
          displayLyric = "🎵 Ready: $title ${artist.isNotEmpty ? '($artist)' : ''}";
        } else if (singer.isNotEmpty) {
          displayLyric = "🎤 @$singer is up next! Awaiting song selection...";
        } else {
          displayLyric = "🎤 Host: Select a participant to sing!";
        }
      }

      String headerTrackInfo = "GloTune Karaoke";
      if (title.isNotEmpty) {
        headerTrackInfo = "$title ${artist.isNotEmpty ? '• $artist' : ''}";
        if (singer.isNotEmpty) {
          headerTrackInfo = "@$singer: $headerTrackInfo";
        }
      } else if (singer.isNotEmpty) {
        headerTrackInfo = "@$singer is choosing a song...";
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [
                    const Color(0xFF3B0764).withValues(alpha: 0.95),
                    const Color(0xFF1E1035).withValues(alpha: 0.95),
                    const Color(0xFF4C0519).withValues(alpha: 0.95),
                  ]
                : [
                    Colors.black.withValues(alpha: 0.8),
                    const Color(0xFF1E1B4B).withValues(alpha: 0.85),
                  ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isActive ? Colors.pinkAccent : Colors.white24,
            width: isActive ? 1.5 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? Colors.pinkAccent : Colors.purpleAccent).withValues(alpha: 0.35),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.pinkAccent : Colors.indigoAccent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.graphic_eq : Icons.music_note,
                        color: Colors.white,
                        size: 11.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        isActive ? "LIVE LYRICS" : "KARAOKE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    headerTrackInfo,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Obx(() => Text(
                    controller.karaokeTimerText.value,
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              ],
            ),
            SizedBox(height: 6.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                displayLyric,
                key: ValueKey<String>(displayLyric),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.pinkAccent.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (nextLyric.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                "Up Next: $nextLyric",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amberAccent.withValues(alpha: 0.9),
                  fontSize: 10.sp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    });
  }

  // MARK: - Top Header
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Host Profile Pill
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final pic = controller.userProfile.value?.profilePictureUrl;
                        return ImageUtils.safeCircleAvatar(
                          radius: 14.r,
                          imageUrl: pic,
                        );
                      }),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
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
              ),

              SizedBox(width: 6.w),

              // Right Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Viewers Count
                  Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 12.sp),
                        SizedBox(width: 3.w),
                        Text(
                          "${controller.liveMemberCount.value}",
                          style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),

                  SizedBox(width: 6.w),

                  // Track Catalog Quick Action Button
                  GestureDetector(
                    onTap: () => _showTrackCatalogSheet(context),
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: Colors.black45,
                      child: const Icon(Icons.queue_music, color: Colors.pinkAccent, size: 15),
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
                    final nextLyric = controller.karaokeNextLyricText.value;
                    final isInstrumental = controller.karaokeCurrentTrackType.value == 'INSTRUMENTAL';
                    final isEligible = controller.karaokeIsRewardEligible.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Live Timed Lyrics Floating Card
                        if (lyric.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            margin: EdgeInsets.only(bottom: 4.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  const Color(0xFF2E1065).withValues(alpha: 0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.pinkAccent, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.music_note, color: Colors.pinkAccent, size: 14),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        lyric,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (nextLyric.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Padding(
                                    padding: EdgeInsets.only(left: 18.w),
                                    child: Text(
                                      "Next: $nextLyric",
                                      style: TextStyle(
                                        color: Colors.amberAccent.withValues(alpha: 0.9),
                                        fontSize: 8.5.sp,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
                              Wrap(
                                spacing: 4.w,
                                runSpacing: 2.h,
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
                                title.isNotEmpty ? title : "Awaiting Song Selection",
                                style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.cyanAccent, size: 11.sp),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      "Artist: ${artist.isNotEmpty ? artist : '—'}",
                                      style: TextStyle(color: Colors.cyanAccent, fontSize: 8.5.sp, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(Icons.mic, color: Colors.pinkAccent, size: 11.sp),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      "Singer: ${singer.isNotEmpty ? '@$singer' : 'No singer assigned'}",
                                      style: TextStyle(color: Colors.pinkAccent, fontSize: 8.5.sp, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
              // Filter out the Host from guest participants (Host is in the left main box)
              final guestParticipants = controller.karaokeParticipants
                  .where((p) => p['role'] != 'HOST' && p['seat'] != '0' && p['role'] != 'host')
                  .toList();
              final remoteUids = controller.remoteUids.toList();

              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(8, (index) {
                  if (index < guestParticipants.length) {
                    final p = guestParticipants[index];
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
            width: isSinger ? 2.0 : 0.5,
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
                constraints: BoxConstraints(maxWidth: 56.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
      onTap: () => _showSelectSingerSheet(context, targetSeat: seatNumber),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pinkAccent, width: 1.5),
                ),
                child: Icon(Icons.person_add, color: Colors.pinkAccent, size: 16.sp),
              ),
              SizedBox(height: 3.h),
              Text(
                "Seat #$seatNumber",
                style: TextStyle(color: Colors.white70, fontSize: 8.sp),
              ),
              Text(
                "Assign Singer",
                style: TextStyle(color: Colors.amberAccent, fontSize: 7.sp, fontWeight: FontWeight.bold),
              ),
            ],
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
              title: const Text("Assign as Next Singer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Grants singing turn; participant can select their song", style: TextStyle(color: Colors.white54, fontSize: 11)),
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

  // MARK: - Select Singer Sheet (Host Picker)
  void _showSelectSingerSheet(BuildContext context, {int? targetSeat}) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        constraints: BoxConstraints(maxHeight: 0.65.sh),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            SizedBox(height: 12.h),
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.pinkAccent),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    targetSeat != null ? "Assign Singer to Seat #$targetSeat" : "Select Participant to Sing",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              "The chosen participant will receive a prompt to select a song and sing live!",
              style: TextStyle(color: Colors.white60, fontSize: 10.sp),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                final List<Map<String, dynamic>> candidates = [];

                // 1. Existing karaoke participants (exclude host)
                for (final p in controller.karaokeParticipants) {
                  if (p['role'] != 'HOST' && p['role'] != 'host') {
                    final uid = p['user_id'] ?? p['id'];
                    if (uid != null && !candidates.any((c) => c['user_id'].toString() == uid.toString())) {
                      candidates.add({
                        'user_id': uid,
                        'username': p['username'] ?? 'Participant $uid',
                        'seat': p['seat']?.toString() ?? "${candidates.length + 1}",
                        'profile_picture': p['profile_picture'],
                      });
                    }
                  }
                }

                // 2. Remote UIDs in room
                for (final uid in controller.remoteUids) {
                  if (!candidates.any((c) => c['user_id'].toString() == uid.toString())) {
                    candidates.add({
                      'user_id': uid,
                      'username': 'Guest $uid',
                      'seat': "${candidates.length + 1}",
                      'profile_picture': null,
                    });
                  }
                }

                // 3. Room live members
                for (final m in controller.liveMembers) {
                  final uid = m is Map ? (m['id'] ?? m['user_id']) : null;
                  if (uid != null && !candidates.any((c) => c['user_id'].toString() == uid.toString())) {
                    candidates.add({
                      'user_id': uid,
                      'username': (m is Map ? (m['username'] ?? m['name']) : null) ?? 'Viewer $uid',
                      'seat': "${candidates.length + 1}",
                      'profile_picture': m is Map ? m['profile_picture'] : null,
                    });
                  }
                }

                if (candidates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, color: Colors.white38, size: 40.sp),
                          SizedBox(height: 8.h),
                          const Text(
                            "No viewers or guests joined yet",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Guests who join your live stream will appear here.",
                            style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: candidates.length,
                  separatorBuilder: (_, _) => Divider(color: Colors.white12, height: 1.h),
                  itemBuilder: (context, idx) {
                    final c = candidates[idx];
                    final uid = c['user_id'] is int ? c['user_id'] as int : int.tryParse(c['user_id'].toString()) ?? 0;
                    final username = c['username']?.toString() ?? 'Guest';
                    final seat = targetSeat != null ? "$targetSeat" : (c['seat']?.toString() ?? "${idx + 1}");
                    final isCurrentSinger = controller.karaokeCurrentSingerId.value == uid && uid > 0;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                      leading: CircleAvatar(
                        backgroundColor: isCurrentSinger ? Colors.pinkAccent : Colors.indigoAccent,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'G',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        "@$username",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isCurrentSinger ? "Currently Singing 🎤" : "Seat #$seat • Tap to assign",
                        style: TextStyle(
                          color: isCurrentSinger ? Colors.pinkAccent : Colors.white54,
                          fontSize: 10.sp,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentSinger ? Colors.white24 : Colors.pinkAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        ),
                        onPressed: () {
                          Get.back();
                          controller.assignKaraokeSinger(uid, seat);
                        },
                        child: Text(
                          isCurrentSinger ? "Assigned" : "Assign to Sing",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  // MARK: - Track Catalog Sheet (PDF Page 1 & 3: PLAYLIST CATEGORY)
  void _showTrackCatalogSheet(BuildContext context) {
    controller.fetchKaraokeCatalog();

    Get.bottomSheet(
      Container(
        height: 0.75.sh,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ),
            SizedBox(height: 10.h),
            
            // Header with Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 32.w),
                Text(
                  "PLAYLIST CATEGORY",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // Two Selectable Category Pills: [Music] [Instrumentals] (PDF Page 1)
            Obx(() {
              final activeCat = controller.selectedKaraokeCategory.value;
              final isMusic = activeCat == 'MUSIC';
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Music Pill
                  GestureDetector(
                    onTap: () => controller.setKaraokeCategory('MUSIC'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isMusic ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isMusic ? Colors.white.withValues(alpha: 0.6) : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: Colors.white, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            "Music",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // Instrumentals Pill
                  GestureDetector(
                    onTap: () => controller.setKaraokeCategory('INSTRUMENTAL'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: !isMusic ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: !isMusic ? Colors.white.withValues(alpha: 0.6) : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.piano, color: Colors.white, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            "Instrumentals",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: 10.h),

            // Category Rule Description Hint (PDF Page 4 & 5)
            Obx(() {
              final isMusic = controller.selectedKaraokeCategory.value == 'MUSIC';
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isMusic
                      ? Colors.purple.withValues(alpha: 0.15)
                      : Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isMusic ? Colors.purpleAccent.withValues(alpha: 0.4) : Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMusic ? Icons.info_outline : Icons.monetization_on_outlined,
                      size: 14.sp,
                      color: isMusic ? Colors.purpleAccent : Colors.amber,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        isMusic
                            ? "Music Mode: Full audio with line-by-line synced lyrics. (No platform b reward)"
                            : "Instrumental Mode: Beat audio only. Completion yields 2/3 platform coin reward (b).",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 10.h),

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
            SizedBox(height: 10.h),
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
                  separatorBuilder: (_, _) => Divider(color: Colors.white12, height: 1.h),
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
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.cyanAccent, size: 12.sp),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  artist.isNotEmpty ? artist : 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "• $durStr",
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
    controller.fetchUserProfile();
    GiftGallerySheet.show(
      context: context,
      userCoins: int.tryParse(controller.userProfile.value?.yourCoins.toString() ?? '0') ?? 0,
      recipientName: name,
      onSend: (gift, quantity) async {
        final totalCoins = (gift.coins * quantity).toDouble();
        controller.sendKaraokeGift(
          receiverUserId: receiverUserId,
          amount: totalCoins,
          giftType: gift.name,
        );
        Get.back();
        Get.snackbar(
          'Gift Sent! 🎁',
          'Sent $quantity x ${gift.name} to @$name!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
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
