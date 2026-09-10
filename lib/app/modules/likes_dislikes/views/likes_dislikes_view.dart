import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/likes_dislikes_controller.dart';

class LikesDislikesView extends GetView<LikesDislikesController> {
  const LikesDislikesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF800000),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Likes and Dislikes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          // Group items by dateGroup
          final grouped = <String, List<dynamic>>{};
          for (var item in controller.items) {
            if (!grouped.containsKey(item.dateGroup)) {
              grouped[item.dateGroup] = [];
            }
            grouped[item.dateGroup]!.add(item);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final group = grouped.keys.elementAt(index);
              final groupItems = grouped[group]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      group,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  ...groupItems.map((item) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        onTap: () => controller.onItemTap(item),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            item.thumbnailUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF000000),
                          ),
                        ),
                        trailing: Icon(
                          item.isLiked ? Icons.thumb_up : Icons.thumb_down,
                          color: const Color(0xFF800000),
                        ),
                      )),
                  const Divider(height: 1),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
