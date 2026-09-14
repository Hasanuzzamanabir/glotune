import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../../controllers/create_controller.dart';

class ModeratorView extends GetView<CreateController> {
  const ModeratorView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final searchQuery = "".obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => controller.navigateTo("LiveStream"),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Moderators',
          style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add / remove moderators",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            Text(
              "Moderators can manage comments and help keep your live stream safe.",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: searchController,
              onChanged: (val) => searchQuery.value = val.trim().toLowerCase(),
              decoration: InputDecoration(
                hintText: "Search viewers to add as moderator...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
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
                final existingMods = controller.moderators;

                final Set<String> seenIds = {};
                final List<Map<String, dynamic>> combined = [];

                for (final mod in existingMods) {
                  final id = (mod['id'] ?? mod['name']).toString();
                  if (!seenIds.contains(id)) {
                    seenIds.add(id);
                    combined.add({
                      'id': mod['id'],
                      'name': mod['name'] ?? 'Moderator',
                      'handle': mod['handle'] ?? '',
                      'avatar': mod['avatar'],
                      'isModerator': true,
                      'raw': mod,
                    });
                  }
                }

                for (final m in allMembers) {
                  final user = m is Map && m['user'] is Map ? m['user'] : (m is Map ? m : {});
                  final id = (user['id'] ?? (m is Map ? m['id'] : null) ?? user['username'] ?? '').toString();
                  if (id.isNotEmpty && !seenIds.contains(id)) {
                    seenIds.add(id);
                    final isMod = (m is Map && (m['role'] == 'moderator' || m['current_user_role'] == 'moderator')) ||
                        existingMods.any((mod) => (mod['id'] != null && mod['id'].toString() == id));
                    combined.add({
                      'id': user['id'] ?? (m is Map ? m['id'] : null),
                      'name': user['full_name'] ?? user['username'] ?? user['name'] ?? 'Viewer',
                      'handle': user['username'] != null ? '@${user['username']}' : '',
                      'avatar': user['profile_picture'] ?? user['avatar'],
                      'isModerator': isMod,
                      'raw': m,
                    });
                  }
                }

                final filtered = combined.where((item) {
                  if (query.isEmpty) return true;
                  final name = (item['name'] ?? '').toString().toLowerCase();
                  final handle = (item['handle'] ?? '').toString().toLowerCase();
                  return name.contains(query) || handle.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 48.sp, color: Colors.grey[300]),
                        SizedBox(height: 12.h),
                        Text(
                          allMembers.isEmpty && existingMods.isEmpty
                              ? "No active viewers or moderators yet"
                              : "No matching members found",
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isMod = item['isModerator'] == true;
                    final avatar = item['avatar'];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 20.r,
                        backgroundImage: (avatar != null && avatar.toString().isNotEmpty)
                            ? NetworkImage(avatar.toString())
                            : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                      ),
                      title: Text(item['name'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        isMod ? "${item['handle']} • Moderator" : item['handle'],
                        style: TextStyle(fontSize: 12.sp, color: isMod ? Colors.blue[700] : AppColors.textSecondary),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          controller.toggleModerator(item['raw'], !isMod);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMod ? Colors.white : AppColors.primary,
                          foregroundColor: isMod ? Colors.red : Colors.white,
                          side: isMod ? const BorderSide(color: Colors.red) : null,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        ),
                        child: Text(isMod ? "Remove" : "Add"),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
