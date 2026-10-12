import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:glotune/app/core/utils/image_utils.dart';
import 'package:glotune/app/modules/create/controllers/create_controller.dart';

class LiveQuizView extends GetView<CreateController> {
  const LiveQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.joinSession("quiz");
      controller.fetchQuizCategories();
      if (controller.quizGameId.value.isEmpty) {
        controller.initOrJoinQuizGame();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF6B1414),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            SizedBox(height: 4.h),
            _buildCategorySelectorBar(),
            SizedBox(height: 4.h),
            _buildQuizMainSection(context),
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

              // Share Button
              CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.black45,
                child: const Icon(Icons.share, color: Colors.white, size: 14),
              ),

              SizedBox(width: 6.w),

              // Close / End Quiz Game Button
              GestureDetector(
                onTap: () => _showExitQuizDialog(context),
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.black45,
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Search & Banner Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32.h,
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

  // MARK: - Category Selector Bar (Dynamic from API)
  Widget _buildCategorySelectorBar() {
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
                      _getCategoryIcon(catName),
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

  IconData _getCategoryIcon(String name) {
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

  // MARK: - Main Quiz Section
  Widget _buildQuizMainSection(BuildContext context) {
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

                // Dark gradient overlay for readable question text
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

                // Host Badge + Category Pill (Clickable to switch category)
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
                            constraints: BoxConstraints(maxWidth: 90.w),
                            child: Text(
                              controller.selectedQuizCategoryName.value.isNotEmpty
                                  ? "Host • ${controller.selectedQuizCategoryName.value}"
                                  : "Host • Select Category",
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

                // Question Box, Category Switcher & Answers A-D
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  right: 8.w,
                  child: Obx(() {
                    final q = controller.activeQuizQuestion.value;
                    final isRoundActive = controller.isQuizRoundActive.value;
                    final answers = controller.activeQuizAnswers.toList();
                    final categories = controller.quizCategories.toList();

                    // Find currently selected category info
                    final currentCat = categories.firstWhereOrNull(
                      (c) => c['id']?.toString() == controller.selectedQuizCategoryId.value ||
                             c['name']?.toString() == controller.selectedQuizCategoryName.value,
                    );

                    String qText;
                    if (q != null && q['question_text'] != null && q['question_text'].toString().isNotEmpty) {
                      qText = q['question_text'].toString();
                    } else if (isRoundActive) {
                      qText = "Loading question from server...";
                    } else if (controller.selectedQuizCategoryName.value.isNotEmpty) {
                      final desc = currentCat?['description']?.toString() ?? '';
                      qText = "🎯 Category: ${controller.selectedQuizCategoryName.value}${desc.isNotEmpty ? '\n$desc' : ''}\nTap 'Start 30s Round' below!";
                    } else {
                      qText = "Select a Category & Start Round";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Question / Category Info Card
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

                        // If round NOT active, show Category Switcher chips from API
                        if (!isRoundActive && categories.isNotEmpty) ...[
                          Container(
                            height: 30.h,
                            margin: EdgeInsets.only(bottom: 2.h),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (context, index) => SizedBox(width: 4.w),
                              itemBuilder: (context, idx) {
                                final cat = categories[idx];
                                final catId = cat['id']?.toString() ?? '';
                                final catName = cat['name']?.toString() ?? '';
                                final isSel = controller.selectedQuizCategoryId.value == catId ||
                                    controller.selectedQuizCategoryName.value == catName;

                                return GestureDetector(
                                  onTap: () => controller.lockQuizCategory(catId, catName),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: isSel ? Colors.amber : Colors.black87,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: isSel ? Colors.white : Colors.white30,
                                        width: isSel ? 1.2 : 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getCategoryIcon(catName),
                                          size: 10.sp,
                                          color: isSel ? Colors.black : Colors.white70,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          catName,
                                          style: TextStyle(
                                            color: isSel ? Colors.black : Colors.white,
                                            fontSize: 7.5.sp,
                                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        // Options A, B, C, D from API
                        if (answers.isNotEmpty)
                          ...answers.map((ans) {
                            final code = ans['option_code']?.toString() ?? 'A';
                            final text = ans['answer_text']?.toString() ?? '';
                            return Padding(
                              padding: EdgeInsets.only(bottom: 3.h),
                              child: _buildQuizOption(code, text),
                            );
                          }),

                        // Host Start 30s Round / Next Question Button
                        if (!controller.isQuizRoundActive.value)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: GestureDetector(
                              onTap: () => controller.startQuizRound(),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE50914),
                                  borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    controller.activeQuizRoundNo.value == 0
                                        ? "Start 30s Round 🚀"
                                        : "Next Question ➡️",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
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

                    return _buildParticipantSlot(
                      name: name,
                      score: score,
                      selectedOption: selectedOpt,
                      isCorrect: isCorrect,
                      userId: uid,
                    );
                  }

                  // Default demo/connected remote co-host or vacant slot
                  if (index < remoteUids.length) {
                    final remoteUid = remoteUids[index];
                    return _buildParticipantSlot(
                      name: "Guest $remoteUid",
                      score: "0 + 0",
                      userId: remoteUid,
                    );
                  }

                  return _buildAddParticipantSlot(context);
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  // MARK: - Option Pill Button
  Widget _buildQuizOption(String code, String text) {
    return Obx(() {
      final isSelected = controller.selectedAnswerOption.value == code;
      final isScored = controller.isQuizScored.value;
      final isCorrect = controller.correctAnswerOption.value == code;

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
          if (!controller.isAnswerSubmitted.value && controller.isQuizRoundActive.value) {
            controller.submitQuizAnswer(code);
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

  // MARK: - Participant Seat Slot
  Widget _buildParticipantSlot({
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
          // Remote Video Stream if connected, otherwise avatar
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
          // Top-left: a + b Reward Score (Fan Gifts a + Platform Rewards b)
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
            child: Container(
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
                            style: TextStyle(color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Icon(
                          Icons.help_outline,
                          color: Colors.white54,
                          size: 10.sp,
                        )),
            ),
          ),

          // Bottom-right: Name Pill with pink '+' Gift Icon
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTap: () => _showSendGiftDialog(userId, name),
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

  // MARK: - Add Participant Slot
  Widget _buildAddParticipantSlot(BuildContext context) {
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
            child: Icon(Icons.add, color: const Color(0xFF6B1414), size: 18.sp),
          ),
        ),
      ),
    );
  }

  // MARK: - Chat Stream
  Widget _buildChatList() {
    return Obx(() {
      final messages = controller.liveMessages;

      if (messages.isEmpty) {
        final mockEvents = [
          {
            "user": " ",
            "text": "Stream Has been Started",
            "isAction": false,
          },
        ];

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          itemCount: mockEvents.length,
          itemBuilder: (context, index) {
            final item = mockEvents[index];
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
                      CircleAvatar(
                        radius: 9.r,
                        backgroundImage: const AssetImage('assets/images/user_avatar.png'),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isSessionNotif = msg is Map &&
              (msg['is_session_notification'] == true ||
                  msg['type'] == 'session_status_notification' ||
                  msg['type'] == 'session_status');
          final text = (msg is Map
                  ? (msg['message'] ?? msg['content'] ?? msg['text'])
                  : msg.toString()) ??
              "";
          final userObj = msg is Map
              ? (msg['user'] is Map ? msg['user'] : msg)
              : {};
          final username = userObj['username'] ??
              userObj['full_name'] ??
              userObj['name'] ??
              "Viewer";
          final avatar = (msg is Map ? msg['profile_picture'] : null) ??
              userObj['profile_picture'] ??
              userObj['avatar'];
          final isAction = msg is Map &&
              (msg['type'] == 'member_action' || msg['is_system'] == true);

          if (isSessionNotif) {
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
                        radius: 9.r,
                        imageUrl: avatar?.toString(),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

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
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                          TextSpan(
                            text: text,
                            style: TextStyle(
                              color: isAction ? Colors.orangeAccent : Colors.white70,
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

  // MARK: - Bottom Action Bar
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
          _buildActionItem(Icons.settings_outlined, "Settings", onTap: () => _showQuizSettings(context)),
          _buildActionItem(Icons.person_add_alt_1_outlined, "Add Guest", onTap: () => _showInviteGuests(context)),
          _buildActionItem(
            Icons.cached_outlined,
            "Switch Game",
            onTap: () => _showSwitchGameSheet(context),
          ),
          _buildActionItem(Icons.chat_bubble_outline, "Comments", onTap: () => _showCommentInputDialog(context)),
          _buildActionItem(Icons.pause, "Pause Live", onTap: () {
            Get.snackbar("Live Paused", "Stream output paused", backgroundColor: Colors.white, colorText: Colors.black);
          }),
          _buildActionItem(
            Icons.more_vert,
            "Category",
            onTap: _showQuizCategoryBottomSheet,
          ),
        ],
      ),
    );
  }

  // MARK: - Category Selection Bottom Sheet
  void _showQuizCategoryBottomSheet() {
    controller.fetchQuizCategories();

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: 0.75.sh),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "QUIZ QUESTIONS\nCATEGORY",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Select category that best fits your questions",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
              ),
              SizedBox(height: 16.h),

              Obx(() {
                if (controller.isLoadingQuizCategories.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFF8B1818))),
                  );
                }

                final List<Map<String, dynamic>> categories = controller.quizCategories.toList();

                if (categories.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_outlined, color: Colors.grey, size: 36.sp),
                          SizedBox(height: 8.h),
                          Text("No quiz categories found on server", style: TextStyle(color: Colors.grey[700], fontSize: 13.sp)),
                          SizedBox(height: 12.h),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B1818),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => controller.fetchQuizCategories(),
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                            label: const Text("Reload Categories", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: categories.map((cat) {
                    final catId = cat['id']?.toString() ?? '';
                    final catName = cat['name']?.toString() ?? '';
                    final catDesc = cat['description']?.toString() ?? '';
                    final qCount = cat['question_count'];
                    final isSelected = controller.selectedQuizCategoryId.value == catId ||
                        controller.selectedQuizCategoryName.value == catName;

                    return GestureDetector(
                      onTap: () {
                        controller.lockQuizCategory(catId, catName);
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B1818) : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF8B1818).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          catName,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (qCount != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white24 : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            "$qCount Questions",
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.grey[700],
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (catDesc.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      catDesc,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white70 : Colors.grey[600],
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected) ...[
                              SizedBox(width: 8.w),
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // MARK: - Send Fan Gift Dialog ($a)
  void _showSendGiftDialog(int recipientUserId, String recipientName) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Send Fan Gift to $recipientName 🎁",
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGiftTile("🌹 Rose", 10.0, recipientUserId),
                _buildGiftTile("🌌 Galaxy", 250.0, recipientUserId),
                _buildGiftTile("💎 Diamond", 500.0, recipientUserId),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftTile(String label, double amount, int recipientUserId) {
    return GestureDetector(
      onTap: () {
        Get.back();
        controller.sendQuizGift(recipientUserId, amount);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text("+$amount pts", style: TextStyle(color: Colors.pinkAccent, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }

  // MARK: - Exit / End Quiz Dialog
  void _showExitQuizDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Exit Quiz Game?",
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                "Ending the quiz will calculate reward holds, host share, and return to standard live.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Get.back();
                        controller.endQuizGame();
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

  // MARK: - Sheets & Utilities
  void _showQuizSettings(BuildContext context) {
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
              child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            SizedBox(height: 16.h),
            Text("Quiz Settings", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.flip_camera_ios),
              title: const Text("Switch Camera"),
              onTap: () {
                Get.back();
                controller.switchCamera();
              },
            ),
            Obx(() => ListTile(
              leading: Icon(controller.isMicMuted.value ? Icons.mic_off : Icons.mic),
              title: const Text("Mute Microphone"),
              trailing: Switch(
                value: controller.isMicMuted.value,
                onChanged: (_) => controller.toggleMic(),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showInviteGuests(BuildContext context) {
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
              child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            SizedBox(height: 16.h),
            Text("Invite Quiz Contestants", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            TextField(
              decoration: InputDecoration(
                hintText: "Search streamers or viewers...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onSubmitted: (query) => controller.gameService.searchUsers(query),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

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
              child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            SizedBox(height: 16.h),
            Text("Switch Game Mode", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: const Text("Standard Live Stream"),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveStream");
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_kabaddi, color: Colors.redAccent),
              title: const Text("1v1 PK Battle"),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveBattle1v1");
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded, color: Colors.deepOrange),
              title: const Text("Box Battle (8 Boxes)"),
              onTap: () {
                Get.back();
                controller.startBoxBattle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.purple),
              title: const Text("2v2 Battle"),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveBattle2v2");
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.pink),
              title: const Text("Karaoke Mode"),
              onTap: () {
                Get.back();
                controller.navigateTo("LiveKaraoke");
              },
            ),
          ],
        ),
      ),
    );
  }

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
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Say something...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    controller.sendLiveMessage(val.trim());
                    Get.back();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.pinkAccent),
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  controller.sendLiveMessage(textController.text.trim());
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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
}
