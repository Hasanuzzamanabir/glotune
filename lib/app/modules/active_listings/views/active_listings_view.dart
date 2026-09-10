import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/modules/inventory_management/views/widgets/inventory_stats_table_layout.dart';
import '../controllers/active_listings_controller.dart';

class ActiveListingsView extends GetView<ActiveListingsController> {
  const ActiveListingsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const InventoryStatsTableLayout(
      title: 'Active Listings',
    );
  }
}
