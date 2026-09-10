import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/search_controller.dart' as sc;

class SearchView extends GetView<sc.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: AppColors.textSecondary),
                  hintText: 'Search',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          // Recent Search Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Recent search',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: controller.recentSearches.length,
              itemBuilder: (context, index) {
                return _buildRecentItem(controller.recentSearches[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String query) {
    return ListTile(
      leading: Icon(Icons.history, color: AppColors.textSecondary, size: 20.sp),
      title: Text(
        query,
        style: TextStyle(
          color: AppColors.textPrimary.withOpacity(0.7),
          fontSize: 14.sp,
        ),
      ),
      onTap: () {},
    );
  }
}
