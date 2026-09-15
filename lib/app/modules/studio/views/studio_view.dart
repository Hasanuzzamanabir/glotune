import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:glotune/app/routes/app_pages.dart';
import '../controllers/studio_controller.dart';

class StudioView extends GetView<StudioController> {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StudioController>()) {
      Get.put(StudioController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Tab Toggle
          _buildTabToggle(),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == "Generate media") {
                return _buildGenerateContent();
              }
              return _buildMergeContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().statusBarHeight + 10.h,
        bottom: 20.h,
        left: 16.w,
        right: 16.w,
      ),
      color: const Color(0xFF8B1D1D),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(Routes.VIEWER_PROFILE),
            child: CircleAvatar(
              radius: 18.r,
              backgroundImage: const AssetImage(
                'assets/images/user_avatar.png',
              ),
            ),
          ),
          const Spacer(),
          _buildHeaderIcon(Icons.history),
          _buildHeaderIcon(
            Icons.settings_outlined,
            onTap: () => Get.toNamed(Routes.SETTINGS),
          ),
          _buildHeaderIcon(Icons.search),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 12.w),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Obx(
              () => Row(
                children: controller.tabs
                    .map((tab) => _buildTabItem(tab))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String tab) {
    bool isSelected = controller.selectedTab.value == tab;
    return GestureDetector(
      onTap: () => controller.setTab(tab),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B1D1D) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          tab,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create content",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                TextField(
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Enter text to generate media",
                    hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _buildSmallActionBtn(
                      Icons.image_outlined,
                      "Gallery",
                      onTap: () => controller.pickVideoAndEdit(),
                    ),
                    SizedBox(width: 12.w),
                    _buildSmallActionBtn(
                      Icons.keyboard_arrow_down,
                      "Convert to",
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Tool Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolIcon(
                  Icons.crop_rotate,
                  onTap: () => controller.pickVideoAndEdit(),
                ),
                _buildToolDivider(),
                _buildToolIcon(
                  Icons.account_tree_outlined,
                  onTap: () => controller.pickVideoAndEdit(),
                ),
                _buildToolDivider(),
                _buildToolIcon(
                  Icons.layers_outlined,
                  onTap: () => controller.pickVideoAndEdit(),
                ),
                _buildToolDivider(),
                _buildToolIcon(
                  Icons.palette_outlined,
                  onTap: () => controller.pickVideoAndEdit(),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          // Action Footer
          Row(
            children: [
              _buildLargeActionBtn(
                "Download",
                const Color(0xFFF1F1F1),
                Colors.black87,
              ),
              SizedBox(width: 12.w),
              _buildLargeActionBtn(
                "Post content",
                const Color(0xFF8B1D1D),
                Colors.white,
              ),
              SizedBox(width: 12.w),
              _buildSaveIconButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: Colors.black.withValues(alpha: 0.7),
        size: 24.sp,
      ),
    );
  }

  Widget _buildToolDivider() {
    return Container(
      height: 20.h,
      width: 1,
      color: Colors.blueGrey.withValues(alpha: 0.1),
    );
  }

  Widget _buildPostContentBtn() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF8B1D1D),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Center(
          child: Text(
            "Post content",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveIconButton() {
    return GestureDetector(
      onTap: _showSaveOptions,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.save,
          color: Colors.black.withValues(alpha: 0.7),
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildMergeContent() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Merge content",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              // Workflow Menu
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.mergeSteps
                      .map((step) => _buildMergeStepItem(step))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        // Placeholders
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 100.h,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.add, color: Colors.grey, size: 30.sp),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        // Proceed Button
        Padding(
          padding: EdgeInsets.all(24.w),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1D1D),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                "Proceed",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMergeStepItem(String step) {
    return Obx(() {
      bool isSelected = controller.activeMergeStep.value == step;
      return GestureDetector(
        onTap: () => controller.setMergeStep(step),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B1D1D)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                step,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (step != controller.mergeSteps.last)
              Icon(Icons.chevron_right, color: Colors.grey[300], size: 16.sp),
          ],
        ),
      );
    });
  }

  Widget _buildSmallActionBtn(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: Colors.black54),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeActionBtn(String label, Color bg, Color text) {
    return Expanded(
      flex: label == "Post content" ? 2 : 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30.r),
          border: label == "Download"
              ? Border.all(color: const Color(0xFFD8D8D8), width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Save",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            _buildSaveItem(Icons.folder_open, "Save to file folder"),
            _buildSaveItem(Icons.perm_media_outlined, "Save to media folder"),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveItem(IconData icon, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF8B1D1D)),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      onTap: () => Get.back(),
    );
  }
}
