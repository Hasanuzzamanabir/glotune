import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:glotune/app/data/models/content_creator.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/manage_creators_controller.dart';

class ManageCreatorsView extends GetView<ManageCreatorsController> {
  const ManageCreatorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Creators',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.error.value,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.fetchCreators,
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        if (controller.creators.isEmpty) {
          return Center(
            child: Text(
              'No creators found.',
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchCreators,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 80.h), // Bottom padding for FAB
            itemCount: controller.creators.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final creator = controller.creators[index];
              return _buildCreatorCard(context, creator, index);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_CREATOR);
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCreatorCard(BuildContext context, ContentCreator creator, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF8B1D1D).withOpacity(0.1),
                radius: 24.r,
                child: Icon(Icons.person, color: const Color(0xFF8B1D1D), size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator.creatorUsername ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      creator.creatorEmail,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {
                  _showBottomSheet(context, index);
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          SizedBox(height: 16.h),
          _buildInfoRow('Talent Type', creator.talentType.toUpperCase()),
          SizedBox(height: 8.h),
          _buildInfoRow('Company Type', creator.companyType.capitalizeFirst ?? ''),
          SizedBox(height: 8.h),
          _buildInfoRow('Management', creator.managementType.replaceAll('_', ' ').capitalizeFirst ?? ''),
          SizedBox(height: 8.h),
          _buildInfoRow('Start Date', dateFormat.format(creator.managementStartDate)),
          if (creator.addComments.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow('Comments', creator.addComments),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Manage creators',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                title: const Text('Remove creators'),
                onTap: () {
                  Navigator.pop(context);
                  controller.removeCreator(index);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                title: const Text('Edit creator\'s info'),
                onTap: () {
                  Navigator.pop(context);
                  controller.editCreator(index);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
