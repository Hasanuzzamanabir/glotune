import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/comments_made_controller.dart';

class CommentsMadeView extends GetView<CommentsMadeController> {
  const CommentsMadeView({super.key});

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
          'Comments made',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return GestureDetector(
                onTap: () => controller.onItemTap(item),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Section: Target video reference
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              item.videoThumbnailUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(width: 40, height: 40, color: Colors.grey[300]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.videoTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Content Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5), // light gray custom container
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.commentText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.timestamp,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
