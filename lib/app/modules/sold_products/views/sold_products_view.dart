import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glotune/app/modules/inventory_management/views/widgets/inventory_stats_table_layout.dart';
import '../controllers/sold_products_controller.dart';

class SoldProductsView extends GetView<SoldProductsController> {
  const SoldProductsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const InventoryStatsTableLayout(
      title: 'Sold',
    );
  }
}
