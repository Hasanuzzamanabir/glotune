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
                if (!controller.isLiveEngineInitialized.value || controller.liveEngine == null) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
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
          Obx(() => CircleAvatar(
            radius: 18.r,
            backgroundImage: controller.userProfile.value?.profilePictureUrl != null
                ? NetworkImage(controller.userProfile.value!.profilePictureUrl!)
                : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
          )),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                controller.userProfile.value?.fullName ?? "Creator", 
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
              )),
              GestureDetector(
                onTap: () => _showLiveMembersList(),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Colors.white, size: 12),
                    SizedBox(width: 4.w),
                    Obx(() => Text(
                      controller.liveMemberCount.value.toString(), 
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
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
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6.w, height: 6.h,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 6.w),
                  Text(timeStr, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => _showEndStreamDialog(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text("END", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
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
          // Comments
          SizedBox(
            height: 150.h,
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.liveMessages.length,
                reverse: true, // Show latest messages at the bottom if we reverse the list, or keep false
                itemBuilder: (context, index) {
                  final msg = controller.liveMessages[index];
                  final username = msg['user']?['username'] ?? "User";
                  final text = msg['message'] ?? "";
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$username: ", style: TextStyle(color: Colors.yellow, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(text, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          
          SizedBox(height: 16.h),
          
          // Bottom Controls
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                child: _buildRoundIcon(Icons.send),
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
          _buildSideIcon(Icons.flip_camera_ios_outlined, onTap: () => controller.switchCamera()),
          _buildSideIcon(Icons.auto_awesome, onTap: () => Get.snackbar("Beauty Mode", "Filters are coming soon!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black)),
          _buildSideIcon(Icons.settings_outlined, onTap: _showDetailedSettings),
          _buildSideIcon(Icons.group_add_outlined, onTap: _showInviteGuests),
          _buildSideIcon(Icons.shield_outlined, onTap: () => controller.navigateTo("ModeratorManage")),
          Obx(() => _buildSideIcon(
            controller.isMicMuted.value ? Icons.mic_off_outlined : Icons.mic_none_outlined, 
            onTap: () => controller.toggleMic()
          )),
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
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildRoundIcon(IconData icon, {Color color = Colors.white}) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  Widget _buildBattleButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp)),
    );
  }

  void _showDetailedSettings() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: 20.h),
              Text("Settings", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              _buildListSetting("Switch Camera", Icons.flip_camera_ios, onTap: () { Get.back(); controller.switchCamera(); }),
              _buildListSetting("Edit stream title", Icons.edit, onTap: () { Get.back(); _showEditTitleDialog(); }),
              _buildListSetting("Beauty Mode", Icons.face, onTap: () { Get.back(); Get.snackbar("Coming Soon", "Beauty mode will be available soon!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black); }),
              _buildListSetting("Video Quality", Icons.hd, onTap: () { Get.back(); Get.snackbar("Quality", "Currently streaming in 720p HD.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black); }),
              _buildListSetting("Moderator", Icons.chevron_right, onTap: () { Get.back(); controller.navigateTo("ModeratorManage"); }),
              _buildListSetting("Pause live", Icons.pause_circle_outline, onTap: () { Get.back(); Get.snackbar("Coming Soon", "Pause live is coming soon!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black); }),
              SizedBox(height: 16.h),
              Text("Layout", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["Panel", "6/12", "Fixed panel", "Fixed grid"].map((l) => _buildLayoutChip(l)).toList(),
              ),
              SizedBox(height: 24.h),
              Text("Comment settings", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              _buildSwitchSetting("Allow comments", true),
              _buildListSetting("Filter comments", Icons.chevron_right, onTap: () { Get.back(); controller.navigateTo("FilterComments"); }),
              _buildListSetting("Block keywords", Icons.chevron_right),
              _buildSwitchSetting("Mute viewers", false, onTap: () { Get.back(); controller.navigateTo("MuteViewers"); }),
              SizedBox(height: 24.h),
              _buildListSetting(
                "Delete stream", 
                Icons.delete_outline, 
                color: Colors.red,
                onTap: () { 
                  Get.back(); 
                  _showDeleteStreamDialog(); 
                }
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
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Invite Co-hosts", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                hintText: "Search viewers or followers...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: controller.liveMembers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_disabled, size: 50.sp, color: Colors.grey[300]),
                        SizedBox(height: 10.h),
                        Text("No one is here yet", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                      ],
                    ),
                  )
                : Obx(() => ListView.builder(
                    itemCount: controller.liveMembers.length,
                    itemBuilder: (context, index) {
                      final member = controller.liveMembers[index];
                      final user = member['user'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                        ),
                        title: Text(user['full_name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user['username'] ?? ''),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
                          onPressed: () {
                            Get.snackbar("Invitation Sent", "Invited ${user['full_name']} to co-host!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
                          },
                          child: const Text("Invite", style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildListSetting(String label, IconData icon, {VoidCallback? onTap, Color color = Colors.black}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontSize: 14.sp, color: color)),
      trailing: Icon(icon, size: 20.sp, color: color),
    );
  }

  Widget _buildSwitchSetting(String label, bool value, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      trailing: Switch(value: value, onChanged: (_) {}, activeThumbColor: AppColors.primary),
    );
  }

  Widget _buildLayoutChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: TextStyle(fontSize: 10.sp)),
    );
  }

  void _showEndStreamDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
              SizedBox(height: 16.h),
              Text("End live stream?", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text("Are you sure you want to stop streaming?", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    controller.endLiveStream(); // end stream and navigate back
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r))),
                  child: const Text("End live now", style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.black))),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTitleDialog() {
    final titleController = TextEditingController(text: controller.liveTitle.value);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Stream Title", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter new title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        controller.liveTitle.value = titleController.text;
                        controller.updateLiveRoom({'title': titleController.text});
                        Get.back();
                        Get.snackbar("Success", "Stream title updated!", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
              ),
              SizedBox(height: 16.h),
              Text("Delete live stream?", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 8.h),
              Text("Are you sure you want to permanently delete this live stream? This action cannot be undone.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    controller.deleteLiveRoom(); // hit DELETE endpoint and close
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r))),
                  child: const Text("Delete now", style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.black))),
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
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: 20.h),
            Text("Live Viewers", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                    // Example of parsing member details depending on backend structure
                    final name = member['user']?['full_name'] ?? member['username'] ?? "Unknown Viewer";
                    final avatar = member['user']?['profile_picture'] ?? member['avatar'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatar != null ? NetworkImage(avatar) : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                      ),
                      title: Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      subtitle: Text("Viewer", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
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
