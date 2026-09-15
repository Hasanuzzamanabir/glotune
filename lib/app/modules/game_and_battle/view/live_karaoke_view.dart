import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/modules/create/controllers/create_controller.dart';

class LiveKaraokeView extends GetView<CreateController> {
  const LiveKaraokeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B1414),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            SizedBox(height: 6.h),
            _buildKaraokeMainSection(),
            Expanded(child: _buildChatList()),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Obx(() {
                      final pic =
                          controller.userProfile.value?.profilePictureUrl;
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
                              (user?.fullName != null &&
                                  user!.fullName!.isNotEmpty)
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
                                    : "Live",
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
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
              CircleAvatar(
                radius: 12.r,
                backgroundImage: const AssetImage(
                  'assets/images/user_avatar.png',
                ),
              ),
              SizedBox(width: 4.w),
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Colors.black45,
                child: Text(
                  "387",
                  style: TextStyle(color: Colors.white, fontSize: 9.sp),
                ),
              ),
              SizedBox(width: 8.w),
              CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.black45,
                child: const Icon(Icons.share, color: Colors.white, size: 14),
              ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: () => controller.navigateTo(
                  controller.isLiveEngineInitialized.value
                      ? "LiveStream"
                      : "Camera",
                ),
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.black45,
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
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
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.search, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white70,
                size: 20.sp,
              ),
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

  Widget _buildKaraokeMainSection() {
    return SizedBox(
      height: 340.h,
      child: Row(
        children: [
          // Left: Host Video + Karaoke Track Details
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/user_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.black, size: 12),
                        Text(
                          "Host",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "VS 01:45",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  left: 12.w,
                  right: 12.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "GUEST: ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "@sam",
                              style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "SONG TITLE: My Love",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "ARTIST: Young Doe",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1.w, color: Colors.white24),
          // Right: 2-Column Participant Grid + Invite Slot
          Expanded(
            flex: 5,
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                _buildParticipantSlot("Usman", "200 + 30"),
                _buildParticipantSlot("Keyza", "200 + 30"),
                _buildParticipantSlot("Judith", "200 + 30"),
                _buildParticipantSlot("Gwen", "200 + 30"),
                _buildParticipantSlot("Tara", "200 + 30"),
                _buildParticipantSlot("Smith", "200 + 30"),
                _buildParticipantSlot("Keyza", "200 + 30"),
                _buildAddParticipantSlot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantSlot(String name, String score) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12, width: 0.5),
        image: const DecorationImage(
          image: AssetImage('assets/images/user_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
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
                  const Icon(
                    Icons.add_circle,
                    color: Colors.pinkAccent,
                    size: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddParticipantSlot() {
    return Container(
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
    );
  }

  Widget _buildChatList() {
    final chatEvents = [
      {"user": "@kay", "text": "shared the live", "isAction": true},
      {"user": "@sambrant", "text": "joined the LIVE 😍", "isAction": true},
      {"user": "@kay", "text": "shared the live", "isAction": true},
      {"user": "@sambrant", "text": "sent you a Rose 🌹", "isAction": true},
      {"user": "@elisa", "text": "I am always enjoying", "isAction": false},
      {"user": "@sambrant", "text": "sent you a Galaxy 🌌", "isAction": true},
      {"user": "@sam", "text": "joined the LIVE", "isAction": true},
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: chatEvents.length,
      itemBuilder: (context, index) {
        final item = chatEvents[index];
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
                    backgroundImage: const AssetImage(
                      'assets/images/user_avatar.png',
                    ),
                  ),
                  SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      children: [
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

  Widget _buildBottomActionBar() {
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
          _buildActionItem(Icons.settings_outlined, "Settings"),
          _buildActionItem(Icons.person_add_alt_1_outlined, "Add Guest"),
          _buildActionItem(
            Icons.cached_outlined,
            "Switch Game",
            onTap: () => controller.navigateTo("Camera"),
          ),
          _buildActionItem(Icons.chat_bubble_outline, "Comments"),
          _buildActionItem(Icons.pause, "Pause Live"),
          _buildActionItem(Icons.more_vert, "Category"),
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
}
