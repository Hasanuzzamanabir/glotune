import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/modules/create/views/live/live_stream_view.dart';
import 'package:glotune/app/modules/create/views/live/moderator_view.dart';
import 'package:glotune/app/modules/create/views/post/edit_post_view.dart';
import 'package:glotune/app/modules/create/views/video/upload_video_view.dart';
import 'package:camera/camera.dart';
import 'package:glotune/app/modules/game_and_battle/view/live_1vs1_view.dart';
import 'package:glotune/app/modules/game_and_battle/view/live_2vs_2view.dart';
import 'package:glotune/app/modules/game_and_battle/view/live_box_battle_view.dart';
import 'package:glotune/app/modules/game_and_battle/view/live_karaoke_view.dart';
import 'package:glotune/app/modules/game_and_battle/view/live_quiz_view.dart';
import '../controllers/create_controller.dart';

class CreateView extends GetView<CreateController> {
  const CreateView({super.key});

@override
  Widget build(BuildContext context) {
    return GetBuilder<CreateController>(
      dispose: (_) {
        final ctrl = Get.find<CreateController>();
        if (!ctrl.isLiveEngineInitialized.value) {
          Get.delete<CreateController>(force: true);
        }
      },
      builder: (_) {
        return Obx(() {
    switch (controller.currentStep.value) {
            case "EditPost":
              return const EditPostView();
            case "UploadVideo":
              return const UploadVideoView();
            case "LiveStream":
              return const LiveStreamView();
            case "ModeratorManage":
              return const ModeratorView();
            case "LiveBattle1v1":
              return const LiveBattle1v1View();
            case "LiveBattle2v2":
              return const LiveBattle2v2View();
            case "LiveQuiz":
              return const LiveQuizView();
            case "LiveKaraoke":
              return const LiveKaraokeView();
            case "LiveBoxBattle":
              return const LiveBoxBattleView();
            default:
              return _buildCameraBase();
          }
        });
      },
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildCameraBase() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview Placeholder
          _buildCameraPreview(),

          // Top Controls
          _buildTopControls(),

          // Side Controls
          _buildSideControls(),

          // Bottom Controls & Gallery (for Posts/Videos)
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      final isCameraTab =
          controller.selectedTab.value == "Shorts" ||
          controller.selectedTab.value == "Live" ||
          controller.selectedTab.value == "Videos";

      if (isCameraTab &&
          controller.isCameraInitialized.value &&
          controller.cameraController != null) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: _applyEffect(
            CameraPreview(controller.cameraController!),
            controller.selectedEffect.value,
          ),
        );
      }
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/signin_option_bg.jpg',
            ), // Placeholder for camera
            fit: BoxFit.cover,
          ),
        ),
        child: Container(color: Colors.black.withOpacity(0.2)),
      );
    });
  }

  Widget _applyEffect(Widget child, String effect) {
    switch (effect) {
      case "B&W":
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0.2126,
            0.7152,
            0.0722,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: child,
        );
      case "Vintage":
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.393,
            0.769,
            0.189,
            0,
            0,
            0.349,
            0.686,
            0.168,
            0,
            0,
            0.272,
            0.534,
            0.131,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: child,
        );
      case "Neon":
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.pinkAccent.withOpacity(0.5),
            BlendMode.colorBurn,
          ),
          child: child,
        );
      case "Sparkles":
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.amber.withOpacity(0.3),
            BlendMode.hardLight,
          ),
          child: child,
        );
      case "Blur":
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: child,
        );
      case "None":
      default:
        return child;
    }
  }

  Widget _buildTopControls() {
    return Positioned(
      top: ScreenUtil().statusBarHeight + 10.h,
      left: 16.w,
      right: 16.w,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
              // Categories Tab Bar
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.tabs.map((tab) {
                          bool isSelected = controller.selectedTab.value == tab;
                          return GestureDetector(
                            onTap: () => controller.setTab(tab),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 48.w), // Spacer for balance
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      top: 150.h,
      right: 16.w,
      child: Obx(
        () => Column(
          children: [
            _buildSideIconButton(
              Icons.flip_camera_ios_outlined,
              "Flip",
              onTap: controller.toggleCamera,
            ),
            _buildSideIconButton(
              controller.isFlashOn.value
                  ? Icons.flash_on
                  : Icons.flash_off_outlined,
              "Flash",
              onTap: controller.toggleFlash,
              isActive: controller.isFlashOn.value,
            ),
            _buildSideIconButton(
              controller.timerSeconds.value > 0
                  ? Icons.timer
                  : Icons.timer_outlined,
              controller.timerSeconds.value > 0
                  ? "${controller.timerSeconds.value}s"
                  : "Timer",
              onTap: controller.toggleTimer,
              isActive: controller.timerSeconds.value > 0,
            ),
            _buildSideIconButton(
              Icons.auto_awesome_outlined,
              "Effects",
              onTap: _showEffectsPanel,
            ),
            _buildSideIconButton(
              Icons.music_note_outlined,
              "Music",
              onTap: _showMusicPanel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideIconButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: 30.h),
        child: Obx(() {
          if (controller.selectedTab.value == "Live") {
            return _buildLiveControls();
          }
          return _buildStandardControls();
        }),
      ),
    );
  }

  Widget _buildStandardControls() {
    return Obx(() {
      if (controller.isRecording.value) {
        return Column(
          children: [
            // Timer display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _formatDuration(controller.recordedSeconds.value),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel
                GestureDetector(
                  onTap: controller.cancelRecording,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                // Shutter Button (Finish)
                GestureDetector(
                  onTap: controller.onShutterButtonPressed,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
                // Pause / Resume
                GestureDetector(
                  onTap: controller.isRecordingPaused.value
                      ? controller.resumeRecording
                      : controller.pauseRecording,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.isRecordingPaused.value
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        controller.isRecordingPaused.value ? "Resume" : "Pause",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }

      // Default (not recording)
      return Column(
        children: [
          // Gallery Preview (Placeholder)
          GestureDetector(
            onTap: () => controller.pickMediaFromGallery(),
            child: Container(
              height: 120.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Container(
                    width: 80.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/user_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text(
                      "Choose from gallery",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Shutter Button
          GestureDetector(
            onTap: controller.onShutterButtonPressed,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70.w,
                  height: 70.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // Widget _buildLiveControls() {
  //   return Column(
  //     children: [
  //       // Live Title Input
  //       Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16.w),
  //         child: TextField(
  //           onChanged: (val) => controller.liveTitle.value = val,
  //           style: const TextStyle(color: Colors.white),
  //           decoration: InputDecoration(
  //             hintText: "Add a title for your live stream...",
  //             hintStyle: const TextStyle(color: Colors.white54),
  //             filled: true,
  //             fillColor: Colors.black.withOpacity(0.5),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12.r),
  //               borderSide: BorderSide.none,
  //             ),
  //             contentPadding: EdgeInsets.symmetric(
  //               horizontal: 16.w,
  //               vertical: 12.h,
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 20.h),
  //       // Live Settings Button
  //       Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16.w),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             _buildLiveActionButton(
  //               Icons.settings_outlined,
  //               "Settings",
  //               onTap: _showLiveSettings,
  //             ),
  //             _buildLiveActionButton(
  //               Icons.group_outlined,
  //               "Guests",
  //               onTap: _showGuestsPanel,
  //             ),
  //             _buildLiveActionButton(
  //               Icons.auto_awesome_motion_outlined,
  //               "Games",
  //               onTap: _showBattlesPanel,
  //             ),
  //             _buildLiveActionButton(
  //               Icons.image_outlined,
  //               "Background",
  //               onTap: _showBackgrounds,
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 30.h),
  //       // Start Live Button
  //       GestureDetector(
  //         onTap: () => controller.startLiveRoom(),
  //         child: Center(
  //           child: Obx(
  //             () => Container(
  //               padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary,
  //                 borderRadius: BorderRadius.circular(30.r),
  //               ),
  //               child: controller.isPosting.value
  //                   ? SizedBox(
  //                       width: 20.w,
  //                       height: 20.h,
  //                       child: const CircularProgressIndicator(
  //                         color: Colors.white,
  //                         strokeWidth: 2,
  //                       ),
  //                     )
  //                   : Text(
  //                       "Go Live",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18.sp,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
Widget _buildLiveControls() {
    return Column(
      children: [
        // Live Title Input
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: controller.liveTitleController,
            onChanged: (val) => controller.liveTitle.value = val,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Add a title for your live stream...",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Main Bordered Action Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.85),
                width: 1.5,
              ),
            ),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLiveActionButton(
                    Icons.settings_outlined,
                    "Settings",
                    isActive: controller.selectedLiveAction.value == "Settings",
                    onTap: () {
                      controller.showGameOptions.value = false;
                      controller.selectedLiveAction.value = "Settings";
                      _showLiveSettings();
                    },
                  ),
                  _buildLiveActionButton(
                    Icons.person_add_alt_1_outlined,
                    "Add Guest",
                    isActive: controller.selectedLiveAction.value == "Add Guest",
                    onTap: () {
                      controller.showGameOptions.value = false;
                      controller.selectedLiveAction.value = "Add Guest";
                      _showGuestsPanel();
                    },
                  ),
                  _buildLiveActionButton(
                    Icons.sports_esports_outlined,
                    "Game",
                    isActive: controller.showGameOptions.value ||
                        controller.selectedLiveAction.value == "Game",
                    onTap: controller.toggleGameMenu,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Sub-menu for Game Options (Shown when Game is tapped)
        Obx(() {
          if (!controller.showGameOptions.value) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.gameOptionsList.map((game) {
                  final isSelected = controller.selectedGameType.value == game;
                  return GestureDetector(
              onTap: () {
  controller.selectedGameType.value = game;
  if (game == "Box battle") {
    controller.navigateTo("LiveBoxBattle");
  } else if (game == "1v1") {
    controller.navigateTo("LiveBattle1v1");
  } else if (game == "Quiz") {
    controller.navigateTo("LiveQuiz");
  } else if (game == "2v2 battle") {
    controller.navigateTo("LiveBattle2v2");
  } else if (game == "Karaoke") {
    controller.navigateTo("LiveKaraoke");
  }
},
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.85),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        game,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 13.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),

        SizedBox(height: 24.h),

        // Start Live Button
        Obx(
          () => GestureDetector(
            onTap: controller.isPosting.value
                ? null
                : () => controller.startLiveRoom(),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: controller.isPosting.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Go Live",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // Widget _buildLiveActionButton(
  //   IconData icon,
  //   String label, {
  //   VoidCallback? onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         Icon(icon, color: Colors.white, size: 28.sp),
  //         SizedBox(height: 4.h),
  //         Text(
  //           label,
  //           style: TextStyle(color: Colors.white, fontSize: 12.sp),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildLiveActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    final activeColor = Colors.red;
    final inactiveColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 26.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveSettings() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Stream Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => _buildSettingItem(
                "Stream Privacy",
                controller.streamPrivacy.value,
                onTap: controller.toggleStreamPrivacy,
              ),
            ),
            Obx(
              () => _buildSettingItem(
                "Latency Mode",
                controller.latencyMode.value,
                onTap: controller.toggleLatencyMode,
              ),
            ),
            Obx(
              () => _buildSettingSwitch(
                "Auto-rotate",
                controller.autoRotate.value,
                (val) => controller.autoRotate.value = val,
              ),
            ),
            Obx(
              () => _buildSettingItem(
                "Audio Settings",
                controller.audioSettings.value,
                onTap: controller.toggleAudioSettings,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String value, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _showGuestsPanel() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Guest Management",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => _buildSettingSwitch(
                "Allow Guests",
                controller.allowGuests.value,
                (val) => controller.allowGuests.value = val,
              ),
            ),
            Obx(
              () => _buildSettingItem(
                "Layout",
                controller.guestLayout.value,
                onTap: () {
                  controller.guestLayout.value =
                      controller.guestLayout.value == "Grid" ? "Panel" : "Grid";
                },
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  "Invite Friends",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showBattlesPanel() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Live Battles",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Challenge other creators to a live match and earn gifts from your viewers!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
            SizedBox(height: 30.h),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isSearchingBattle.value
                        ? Colors.red
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    controller.isSearchingBattle.value =
                        !controller.isSearchingBattle.value;
                  },
                  child: Text(
                    controller.isSearchingBattle.value
                        ? "Cancel Search..."
                        : "Match with Random Host",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showBackgrounds() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        height: 400.h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Choose Background",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.selectedLiveBackground.value = -1,
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Obx(() {
                    bool isSelected =
                        controller.selectedLiveBackground.value == index;
                    return GestureDetector(
                      onTap: () =>
                          controller.selectedLiveBackground.value = index,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/user_avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEffectsPanel() {
    final effects = [
      {"name": "None", "icon": Icons.block, "color": Colors.grey},
      {"name": "Sparkles", "icon": Icons.auto_awesome, "color": Colors.amber},
      {"name": "Vintage", "icon": Icons.camera_alt, "color": Colors.brown},
      {"name": "B&W", "icon": Icons.monochrome_photos, "color": Colors.black},
      {"name": "Neon", "icon": Icons.lightbulb_outline, "color": Colors.pink},
      {"name": "Blur", "icon": Icons.blur_on, "color": Colors.blue},
    ];

    Get.bottomSheet(
      Container(
        height: 180.h,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Effects",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: effects.length,
                itemBuilder: (context, index) {
                  final effect = effects[index];
                  return Obx(() {
                    bool isSelected =
                        controller.selectedEffect.value == effect['name'];
                    return GestureDetector(
                      onTap: () {
                        controller.selectedEffect.value =
                            effect['name'] as String;
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: (effect['color'] as Color).withOpacity(
                                  0.3,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                effect['icon'] as IconData,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              effect['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
          ],
        ),
      ),
      barrierColor:
          Colors.transparent, // Allow user to see camera behind the panel
    );
  }

  void _showMusicPanel() {
    final musicTracks = [
      {"name": "None", "artist": "", "duration": ""},
      {"name": "Viral Beat 1", "artist": "DJ Max", "duration": "0:30"},
      {"name": "Chill Lo-Fi", "artist": "Studying Beats", "duration": "1:00"},
      {
        "name": "Epic Soundtrack",
        "artist": "Cinematic Pro",
        "duration": "0:45",
      },
      {"name": "Pop Hits", "artist": "Top 40", "duration": "0:15"},
      {"name": "Acoustic Vibes", "artist": "Guitar Guy", "duration": "0:20"},
    ];

    Get.bottomSheet(
      Container(
        height: 400.h,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Music",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.search, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView.builder(
                itemCount: musicTracks.length,
                itemBuilder: (context, index) {
                  final track = musicTracks[index];
                  return Obx(() {
                    bool isSelected =
                        controller.selectedMusic.value == track['name'];
                    return ListTile(
                      onTap: () {
                        controller.selectedMusic.value =
                            track['name'] as String;
                      },
                      leading: Container(
                        width: 45.w,
                        height: 45.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          track['name'] == 'None'
                              ? Icons.block
                              : Icons.music_note,
                          color: isSelected ? AppColors.primary : Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      title: Text(
                        track['name'] as String,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14.sp,
                        ),
                      ),
                      subtitle: track['artist'] != ""
                          ? Text(
                              track['artist'] as String,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12.sp,
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : Text(
                              track['duration'] as String,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12.sp,
                              ),
                            ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.transparent, // Allow seeing camera
    );
  }
}
