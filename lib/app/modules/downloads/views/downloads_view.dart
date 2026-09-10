import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../controllers/downloads_controller.dart';
import '../models/download_item_model.dart';

class DownloadsView extends GetView<DownloadsController> {
  const DownloadsView({super.key});

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
          'Downloads',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            itemCount: controller.downloads.length,
            itemBuilder: (context, index) {
              final item = controller.downloads[index];
              return DownloadCard(
                item: item,
                onTap: () => controller.onItemTap(item),
                onOptionsTap: () => controller.onOptionsTap(item),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DownloadCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const DownloadCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.thumbnailUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error)),
                    );
                  },
                ),
              ),
            ),
            // Metadata Row
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading: Creator profile image
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(item.creatorProfileUrl),
                    onBackgroundImageError: (_, _) {},
                    child: item.creatorProfileUrl.isEmpty
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Center: Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trailing: Options Icon
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF000000)),
                    onPressed: onOptionsTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
