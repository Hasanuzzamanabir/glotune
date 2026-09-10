import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/modules/inventory_management/views/widgets/inventory_stats_table_layout.dart';
import '../controllers/total_products_controller.dart';

class TotalProductsView extends GetView<TotalProductsController> {
  const TotalProductsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const InventoryStatsTableLayout(
      title: 'Total Products',
    );
  }
}
