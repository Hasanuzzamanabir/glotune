import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/engagement_history_controller.dart';

class EngagementHistoryView extends GetView<EngagementHistoryController> {
  const EngagementHistoryView({super.key});

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
          'Engagement history',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFFFFFF),
            child: TabBar(
              controller: controller.tabController,
              indicatorColor: const Color(0xFF800000),
              labelColor: const Color(0xFF800000),
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3.0,
              tabs: const [
                Tab(text: "My activities"),
                Tab(text: "Talent managers"),
                Tab(text: "Content creators"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildMyActivitiesTab(),
                const Center(child: Text("Talent managers")),
                const Center(child: Text("Content creators")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyActivitiesTab() {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: controller.menuItems.length,
        itemBuilder: (context, index) {
          final item = controller.menuItems[index];
          return HistoryMenuTile(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            onTap: () => controller.onMenuItemTap(item),
          );
        },
      ),
    );
  }
}

class HistoryMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HistoryMenuTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF800000).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF800000),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
    );
  }
}
