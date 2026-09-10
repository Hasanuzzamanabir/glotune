import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/videos_watched_controller.dart';

class VideosWatchedView extends GetView<VideosWatchedController> {
  const VideosWatchedView({super.key});

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
          'Videos watched',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            itemCount: controller.videos.length,
            itemBuilder: (context, index) {
              final item = controller.videos[index];
              return GestureDetector(
                onTap: () => controller.onVideoTap(item),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Element
                      SizedBox(
                        width: 140,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  item.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(color: Colors.grey[300]),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.duration,
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right Element
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.timestamp,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetric(Icons.thumb_up_alt_outlined, item.likes.toString()),
                                _buildMetric(Icons.chat_bubble_outline, item.comments.toString()),
                                _buildMetric(Icons.visibility_outlined, item.views.toString()),
                                _buildMetric(Icons.share_outlined, item.shares.toString()),
                              ],
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

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF757575)),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 10, color: Color(0xFF757575))),
      ],
    );
  }
}
