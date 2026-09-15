import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../../controllers/create_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveStreamView extends GetView<CreateController> {
  const LiveStreamView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return controller.minimizeToPip(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Stream Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Obx(() {
                if (!controller.isLiveEngineInitialized.value ||
                    controller.liveEngine == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: controller.liveEngine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                );
              }),
            ),

            // Overlays
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildStreamHeader(),

                  const Spacer(),

                  // Interaction Area
                  _buildInteractionArea(),
                ],
              ),
            ),

            // Side Controls
            _buildLiveSideControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Obx(() {
            final user = controller.userProfile.value;
            final pic = user?.profilePictureUrl;
            return CircleAvatar(
              radius: 18.r,
              backgroundImage: (pic != null && pic.isNotEmpty)
                  ? NetworkImage(pic)
                  : const AssetImage('assets/images/user_avatar.png')
                        as ImageProvider,
            );
          }),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final user = controller.userProfile.value;
                  final name =
                      (user?.fullName != null && user!.fullName!.isNotEmpty)
                      ? user.fullName!
                      : "Creator";
                  return Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                Obx(() {
                  final title = controller.liveTitle.value;
                  if (title.isEmpty) return const SizedBox.shrink();
                  return Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                  );
                }),
                GestureDetector(
                  onTap: () => _showLiveMembersList(),
                  child: Row(
                    children: [
                      const Icon(Icons.group, color: Colors.white70, size: 12),
                      SizedBox(width: 4.w),
                      Obx(
                        () => Text(
                          "${controller.liveMemberCount.value} viewers",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final seconds = controller.liveDurationSeconds.value;
            if (seconds == 0) return const SizedBox.shrink();

            final h = seconds ~/ 3600;
            final m = (seconds % 3600) ~/ 60;
            final s = seconds % 60;
            final timeStr = h > 0
                ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
                : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

            return Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: () => _showEndStreamDialog(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "END",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionArea() {
    final messageController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Dynamic Comments
          SizedBox(
            height: 150.h,
            child: Obx(() {
              if (controller.liveMessages.isEmpty) {
                return Center(
                  child: Text(
                    "No messages yet. Say something!",
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.liveMessages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final msg = controller.liveMessages[index];
                  final userObj = msg is Map
                      ? (msg['user'] is Map ? msg['user'] : msg)
                      : {};
                  final username =
                      userObj['username'] ??
                      userObj['full_name'] ??
                      userObj['name'] ??
                      "Viewer";
                  final text =
                      (msg is Map
                          ? (msg['message'] ?? msg['content'] ?? msg['text'])
                          : msg.toString()) ??
                      "";
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$username: ",
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          SizedBox(height: 12.h),

          // Bottom Controls
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Say something...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        controller.sendLiveMessage(val);
                        messageController.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  if (messageController.text.trim().isNotEmpty) {
                    controller.sendLiveMessage(messageController.text);
                    messageController.clear();
                  }
                },
                child: _buildRoundIcon(Icons.send, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSideControls() {
    return Positioned(
      top: 150.h,
      right: 16.w,
      child: Column(
        children: [
          _buildSideIcon(
            Icons.flip_camera_ios_outlined,
            onTap: () => controller.switchCamera(),
          ),
          _buildSideIcon(
            Icons.auto_awesome,
            onTap: () => Get.snackbar(
              "Beauty Mode",
              "Filters are coming soon!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
              colorText: Colors.black,
            ),
          ),
          _buildSideIcon(Icons.settings_outlined, onTap: _showDetailedSettings),
          _buildSideIcon(Icons.group_add_outlined, onTap: _showInviteGuests),
          _buildSideIcon(
            Icons.shield_outlined,
            onTap: () => controller.navigateTo("ModeratorManage"),
          ),
          Obx(
            () => _buildSideIcon(
              controller.isMicMuted.value
                  ? Icons.mic_off_outlined
                  : Icons.mic_none_outlined,
              onTap: () => controller.toggleMic(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildRoundIcon(IconData icon, {Color color = Colors.white}) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  Widget _buildBattleButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 10.sp),
      ),
    );
  }

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
                "Moderator",
                Icons.chevron_right,
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
                    "Coming Soon",
                    "Pause live is coming soon!",
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

  void _showInviteGuests() {
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
                  "Invite Co-hosts",
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
                hintText: "Search viewers or followers...",
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
                  return name.contains(query) || username.contains(query);
                }).toList();

                if (filtered.isEmpty) {
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
                              ? "No one is here yet"
                              : "No matching viewers found",
                          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    final user = member is Map && member['user'] is Map
                        ? member['user']
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
                        user['id'] ?? (member is Map ? member['id'] : null);

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
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () {
                          print(
                            "[DEBUG LIVE] Inviting guest: $name (id: $userId)",
                          );
                          controller.inviteGuest(userId);
                        },
                        child: const Text(
                          "Invite",
                          style: TextStyle(color: Colors.white),
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
                    Get.back(); // close dialog
                    controller.endLiveStream(); // end stream and navigate back
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
                    Get.back(); // close dialog
                    controller
                        .deleteLiveRoom(); // hit DELETE endpoint and close
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

  void _showLiveMembersList() {
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
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: role.toString().toLowerCase() == "host"
                              ? Colors.amber.withValues(alpha: 0.2)
                              : (role.toString().toLowerCase() == "moderator"
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          role.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: role.toString().toLowerCase() == "host"
                                ? Colors.orange[800]
                                : (role.toString().toLowerCase() == "moderator"
                                      ? Colors.blue[800]
                                      : Colors.grey[700]),
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
}
