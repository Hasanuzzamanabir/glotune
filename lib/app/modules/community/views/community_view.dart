// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:glotune/app/core/values/app_colors.dart';
// import 'package:glotune/app/routes/app_pages.dart';
// import '../controllers/community_controller.dart';
// import '../../home/controllers/home_controller.dart' as glotune_home_controller;

// class CommunityView extends GetView<CommunityController> {
//   final bool isEmbedded;
//   const CommunityView({super.key, this.isEmbedded = false});

//   @override
//   Widget build(BuildContext context) {
//     Widget body = Column(
//       children: [
//         // Tab Bar
//         _buildTabBar(),
        
//         // Content
//         Expanded(
//           child: Stack(
//             children: [
//               Obx(() {
//                 if (controller.selectedTab.value == "Friends") return _buildFriendsList();
//                 if (controller.selectedTab.value == "Pending request") return _buildPendingRequests();
//                 return _buildInbox();
//               }),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: _buildBottomButtons(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );

//     if (isEmbedded) {
//       return body;
//     }

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         leading: const BackButton(color: Colors.white),
//         title: Image.asset('assets/images/logo.png', height: 24.h), // Reusing logo if available
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.cast, color: Colors.white)),
//           GestureDetector(
//             onTap: () async {
//               await Get.toNamed(Routes.NOTIFICATIONS);
//               if (Get.isRegistered<glotune_home_controller.HomeController>()) {
//                 Get.find<glotune_home_controller.HomeController>().fetchUnreadNotificationCount();
//               }
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12.0),
//                   child: Icon(Icons.notifications_none, color: Colors.white),
//                 ),
//                 Obx(() {
//                   if (Get.isRegistered<glotune_home_controller.HomeController>()) {
//                     final homeCtrl = Get.find<glotune_home_controller.HomeController>();
//                     if (homeCtrl.unreadNotificationCount.value > 0) {
//                       return Positioned(
//                         right: 8,
//                         top: 12,
//                         child: Container(
//                           padding: const EdgeInsets.all(2),
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                           constraints: const BoxConstraints(
//                             minWidth: 14,
//                             minHeight: 14,
//                           ),
//                           child: Text(
//                             homeCtrl.unreadNotificationCount.value > 99
//                                 ? '99+'
//                                 : '${homeCtrl.unreadNotificationCount.value}',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 8.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       );
//                     }
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//             ),
//           ),
//           IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
//         ],
//       ),
//       body: body,
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 16.h),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: ["Friends", "Pending request", "Inbox"].map((tab) => _buildTabItem(tab)).toList(),
//       ),
//     );
//   }

//   Widget _buildTabItem(String tab) {
//     return Obx(() {
//       bool isSelected = controller.selectedTab.value == tab;
//       return GestureDetector(
//         onTap: () => controller.setTab(tab),
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//           decoration: BoxDecoration(
//             color: isSelected ? AppColors.primary : Colors.transparent,
//             borderRadius: BorderRadius.circular(20.r),
//             border: isSelected ? null : Border.all(color: AppColors.border),
//           ),
//           child: Text(
//             tab,
//             style: TextStyle(
//               color: isSelected ? Colors.white : AppColors.textSecondary,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               fontSize: 12.sp,
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildFriendsList() {
//     return Obx(() {
//       if (controller.isFriendsLoading.value) {
//         return const Center(child: CircularProgressIndicator(color: AppColors.primary));
//       }
      
//       if (controller.friends.isEmpty) {
//         return Center(
//           child: Text(
//             "No friends found.",
//             style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
//           ),
//         );
//       }

//       return ListView.builder(
//         padding: EdgeInsets.only(bottom: 100.h),
//         itemCount: controller.friends.length,
//         itemBuilder: (context, index) {
//           final friend = controller.friends[index];
//           final avatarUrl = friend['profile_picture'] as String?;
          
//           return ListTile(
//             contentPadding: EdgeInsets.all(16.w),
//             leading: CircleAvatar(
//               radius: 24.r,
//               backgroundColor: Colors.grey[200],
//               backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
//                   ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
//                   : const AssetImage('assets/images/user_avatar.png'),
//             ),
//             title: Text(friend['full_name'] ?? 'Unknown', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
//             subtitle: Text("${friend['subscriber_count'] ?? 0} Subscribers", style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
//             trailing: ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//                 elevation: 0,
//               ),
//               child: const Text("Remove"),
//             ),
//           );
//         },
//       );
//     });
//   }

//   Widget _buildPendingRequests() {
//     return ListView.builder(
//       padding: EdgeInsets.only(bottom: 100.h),
//       itemCount: controller.pendingRequests.length,
//       itemBuilder: (context, index) {
//         final req = controller.pendingRequests[index];
//         return ListTile(
//           contentPadding: EdgeInsets.all(16.w),
//           leading: CircleAvatar(radius: 24.r, backgroundImage: const AssetImage('assets/images/user_avatar.png')),
//           title: Text(req['name']!, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextButton(onPressed: () {}, child: Text("Decline", style: TextStyle(color: AppColors.textSecondary))),
//               SizedBox(width: 8.w),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//                   elevation: 0,
//                 ),
//                 child: const Text("Accept"),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildInbox() {
//     return Obx(() {
//       if (controller.isInboxLoading.value) {
//         return const Center(child: CircularProgressIndicator(color: AppColors.primary));
//       }
//       if (controller.inbox.isEmpty) {
//         return Center(
//           child: Text("No chats available.", style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
//         );
//       }
//       return ListView.builder(
//         padding: EdgeInsets.only(bottom: 100.h),
//         itemCount: controller.inbox.length,
//         itemBuilder: (context, index) {
//           final item = controller.inbox[index];
//           final otherUser = item['other_user'] as String? ?? 'User';
//           final lastMsg = item['last_message'] as String? ?? '';
          
//           final timeRaw = item['last_message_time'] ?? item['created_at'] ?? '';
//           final timeStr = timeRaw.toString().length >= 10 ? timeRaw.toString().substring(0, 10) : '';
          
//           final unreadRaw = item['unread_count'];
//           int unreadCount = 0;
//           if (unreadRaw != null) {
//             unreadCount = int.tryParse(unreadRaw.toString()) ?? 0;
//           }

//           return ListTile(
//             onTap: () => Get.toNamed(Routes.CHAT, arguments: item),
//             contentPadding: EdgeInsets.all(16.w),
//             leading: CircleAvatar(
//               radius: 24.r,
//               backgroundColor: Colors.grey[200],
//               backgroundImage: const AssetImage('assets/images/user_avatar.png')
//             ),
//             title: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(otherUser, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(timeStr, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
//               ],
//             ),
//             subtitle: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     lastMsg,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
//                       fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis
//                   )
//                 ),
//                 if (unreadCount > 0) ...[
//                   SizedBox(width: 8.w),
//                   Container(
//                     padding: EdgeInsets.all(6.w),
//                     decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                     child: Text(
//                       unreadCount > 99 ? '99+' : unreadCount.toString(),
//                       style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       );
//     });
//   }

//   Widget _buildBottomButtons() {
//     return Container(
//       height: 120.h,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.white.withOpacity(0.0),
//             Colors.white.withOpacity(0.8),
//             Colors.white,
//           ],
//           stops: const [0.0, 0.4, 1.0],
//         ),
//       ),
//       padding: EdgeInsets.only(bottom: 24.h),
//       alignment: Alignment.bottomCenter,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildActionButton(
//             title: "New Group",
//             icon: Container(
//               padding: EdgeInsets.all(4.w),
//               decoration: const BoxDecoration(
//                 color: AppColors.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.add, color: Colors.white, size: 16.sp),
//             ),
//             borderColor: const Color(0xFFFFE4E4),
//             onTap: () => Get.toNamed(Routes.CREATE_GROUP),
//           ),
//           SizedBox(width: 16.w),
//           _buildActionButton(
//             title: "Groups",
//             icon: Icon(Icons.people_outline, color: AppColors.textSecondary, size: 24.sp),
//             borderColor: AppColors.border,
//             onTap: () => Get.toNamed(Routes.GROUPS),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required String title,
//     required Widget icon,
//     required Color borderColor,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(30.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30.r),
//           border: Border.all(color: borderColor),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             icon,
//             SizedBox(width: 10.w),
//             Text(
//               title,
//               style: TextStyle(
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14.sp,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/community_controller.dart';
import '../../home/controllers/home_controller.dart' as glotune_home_controller;

class CommunityView extends GetView<CommunityController> {
  final bool isEmbedded;
  const CommunityView({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: Stack(
            children: [
              Obx(() {
                if (controller.selectedTab.value == "Friends") return _buildFriendsList();
                if (controller.selectedTab.value == "Pending request") return _buildPendingRequests();
                return _buildInbox();
              }),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomButtons(context),
              ),
            ],
          ),
        ),
      ],
    );

    if (isEmbedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Image.asset('assets/images/logo.png', height: 24.h),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.cast, color: Colors.white),
          ),
          GestureDetector(
            onTap: () async {
              await Get.toNamed(Routes.NOTIFICATIONS);
              if (Get.isRegistered<glotune_home_controller.HomeController>()) {
                Get.find<glotune_home_controller.HomeController>().fetchUnreadNotificationCount();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.notifications_none, color: Colors.white),
                ),
                Obx(() {
                  if (Get.isRegistered<glotune_home_controller.HomeController>()) {
                    final homeCtrl = Get.find<glotune_home_controller.HomeController>();
                    if (homeCtrl.unreadNotificationCount.value > 0) {
                      return Positioned(
                        right: 8,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Text(
                            homeCtrl.unreadNotificationCount.value > 99
                                ? '99+'
                                : '${homeCtrl.unreadNotificationCount.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openAddFriendBottomSheet(context),
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ["Friends", "Pending request", "Inbox"].map((tab) => _buildTabItem(tab)).toList(),
      ),
    );
  }

  Widget _buildTabItem(String tab) {
    return Obx(() {
      bool isSelected = controller.selectedTab.value == tab;
      return GestureDetector(
        onTap: () => controller.setTab(tab),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            tab,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12.sp,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFriendsList() {
    return Obx(() {
      if (controller.isFriendsLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.friends.isEmpty) {
        return Center(
          child: Text(
            "No friends found.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchFriends(),
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 100.h),
          itemCount: controller.friends.length,
          itemBuilder: (context, index) {
            final friend = controller.friends[index];
            final avatarUrl = friend['profile_picture'] as String?;
            final name = (friend['full_name'] != null && friend['full_name'].toString().trim().isNotEmpty)
                ? friend['full_name']
                : (friend['username'] ?? friend['email'] ?? 'User');

            return ListTile(
              contentPadding: EdgeInsets.all(16.w),
              leading: CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
                    : const AssetImage('assets/images/user_avatar.png'),
              ),
              title: Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${friend['subscriber_count'] ?? 0} Subscribers",
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  elevation: 0,
                ),
                child: const Text("Message"),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPendingRequests() {
    return Obx(() {
      if (controller.isRequestsLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.pendingRequests.isEmpty) {
        return Center(
          child: Text(
            "No pending requests.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchPendingRequests(),
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 100.h),
          itemCount: controller.pendingRequests.length,
          itemBuilder: (context, index) {
            final req = controller.pendingRequests[index];
            final sender = req['sender'] is Map ? req['sender'] : req;
            final userId = sender['id'] ?? req['user_id'] ?? req['id'];
            final name = (sender['full_name'] != null && sender['full_name'].toString().trim().isNotEmpty)
                ? sender['full_name']
                : (sender['username'] ?? sender['email'] ?? 'Unknown');
            final avatarUrl = sender['profile_picture'] as String?;

            return ListTile(
              contentPadding: EdgeInsets.all(16.w),
              leading: CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
                    : const AssetImage('assets/images/user_avatar.png'),
              ),
              title: Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      if (userId != null) controller.declineFriendRequest(userId);
                    },
                    child: Text("Decline", style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      if (userId != null) controller.acceptFriendRequest(userId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      elevation: 0,
                    ),
                    child: const Text("Accept"),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildInbox() {
    return Obx(() {
      if (controller.isInboxLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (controller.inbox.isEmpty) {
        return Center(
          child: Text(
            "No chats available.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchChatList(),
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 100.h),
          itemCount: controller.inbox.length,
          itemBuilder: (context, index) {
            final item = controller.inbox[index];
            final otherUser = item['other_user'] as String? ?? 'User';
            final lastMsg = item['last_message'] as String? ?? '';
            final timeRaw = item['last_message_time'] ?? item['created_at'] ?? '';
            final timeStr = timeRaw.toString().length >= 10 ? timeRaw.toString().substring(0, 10) : '';

            final unreadRaw = item['unread_count'];
            int unreadCount = 0;
            if (unreadRaw != null) {
              unreadCount = int.tryParse(unreadRaw.toString()) ?? 0;
            }

            return ListTile(
              onTap: () => Get.toNamed(Routes.CHAT, arguments: item),
              contentPadding: EdgeInsets.all(16.w),
              leading: CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: const AssetImage('assets/images/user_avatar.png'),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      otherUser,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(timeStr, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      lastMsg,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.8),
            Colors.white,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      padding: EdgeInsets.only(bottom: 24.h),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            title: "New Group",
            icon: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Icons.add, color: Colors.white, size: 16.sp),
            ),
            borderColor: const Color(0xFFFFE4E4),
            onTap: () => Get.toNamed(Routes.CREATE_GROUP),
          ),
          SizedBox(width: 16.w),
          _buildActionButton(
            title: "Add Friend",
            icon: Icon(Icons.person_add_outlined, color: AppColors.textSecondary, size: 22.sp),
            borderColor: AppColors.border,
            onTap: () => _openAddFriendBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Widget icon,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddFriendBottomSheet(BuildContext context) {
    controller.fetchAllUsers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          height: 0.75.sh,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Text(
                "Find People",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  if (controller.isUsersLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (controller.allUsers.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }
                  return ListView.builder(
                    itemCount: controller.allUsers.length,
                    itemBuilder: (context, index) {
                      final user = controller.allUsers[index];
                      final int? userId = user['id'];
                      final name = (user['full_name'] != null && user['full_name'].toString().trim().isNotEmpty)
                          ? user['full_name']
                          : (user['username'] ?? user['email'] ?? 'User');
                      final userType = user['user_type'] ?? 'Viewer';
                      final avatarUrl = user['profile_picture'] as String?;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? CachedNetworkImageProvider(avatarUrl) as ImageProvider
                              : const AssetImage('assets/images/user_avatar.png'),
                        ),
                        title: Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        subtitle: Text(userType, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                        trailing: Obx(() {
                          final bool isSent = userId != null && controller.sentRequestUserIds.contains(userId);

                          if (isSent) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 14.sp, color: Colors.grey[700]),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Sent",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ElevatedButton(
                            onPressed: () {
                              if (userId != null) {
                                controller.sendFriendRequest(userId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                              elevation: 0,
                            ),
                            child: const Text("Add"),
                          );
                        }),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}