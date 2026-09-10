import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/video_shared_controller.dart';

class VideoSharedView extends GetView<VideoSharedController> {
  const VideoSharedView({super.key});

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
          'Video shared',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  '${item.videoTitle} shared to ${item.platform}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF000000),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    item.timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new, color: Color(0xFF000000)),
                  onPressed: () => controller.onOutboundTap(item),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
