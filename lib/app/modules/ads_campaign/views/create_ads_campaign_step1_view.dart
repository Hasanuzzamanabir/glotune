import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import '../controllers/ads_campaign_controller.dart';
import 'create_ads_campaign_step2_view.dart';

class CreateAdsCampaignStep1View extends GetView<AdsCampaignController> {
  const CreateAdsCampaignStep1View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ads Campaign',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Ads Campaign Name'),
              _buildTextField(
                'Your campaign name',
                controller: controller.titleController,
              ),
              SizedBox(height: 16.h),

              _buildLabel('Choose Ad Campaign Type'),
              _buildDropdown(),

              SizedBox(height: 24.h),
              _buildLabel('Upload Proposal'),
              _buildUploadBox(),

              SizedBox(height: 24.h),
              _buildSpecsTable(),

              SizedBox(height: 32.h),
              _buildProceedButton(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return GestureDetector(
      onTap: () => _showDropdownSheet(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() {
                final selected = controller.selectedCampaignType.value;
                if (selected == null) {
                  return Text(
                    'Choose',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                  );
                } else {
                  return Text(
                    selected.split('\n').first,
                    style: TextStyle(color: Colors.black87, fontSize: 14.sp),
                    overflow: TextOverflow.ellipsis,
                  );
                }
              }),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showDropdownSheet() {
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.only(top: 60.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBFF), // very light blue tint
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 24.h),
                itemCount: controller.campaignTypes.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final type = controller.campaignTypes[index];
                  final parts = type.split('\n');
                  return InkWell(
                    onTap: () {
                      // Update both for UI compatibility and API payload
                      controller.selectedCampaignType.value = type;
                      if (type.toLowerCase().contains("splash") ||
                          type.toLowerCase().contains("awareness")) {
                        controller.selectedCampaignTypeEnum.value = "awareness";
                      } else if (type.toLowerCase().contains("roll") ||
                          type.toLowerCase().contains("display") ||
                          type.toLowerCase().contains("engagement")) {
                        controller.selectedCampaignTypeEnum.value =
                            "engagement";
                      } else {
                        controller.selectedCampaignTypeEnum.value =
                            "conversion";
                      }
                      Get.back();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parts[0],
                            style: TextStyle(
                              color: Colors.black87.withValues(alpha: 0.7),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (parts.length > 1) ...[
                            SizedBox(height: 4.h),
                            Text(
                              parts[1],
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: () => controller.pickFile(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_upload_rounded,
              color: Colors.grey[800],
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Obx(
                () => Text(
                  controller.selectedFileName.value ?? 'MP4, JPG, PNG, WEBP',
                  style: TextStyle(
                    color: controller.selectedFileName.value == null
                        ? Colors.grey[400]
                        : Colors.black87,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          _buildTableRow([
            'Ads',
            'Dimension',
            'Size',
            'Format',
            'Ratio',
          ], isHeader: true),
          _buildTableRow([
            'Pre, mid\nPost-roll',
            '1920 x 1080px',
            '50mb',
            'Mp4',
            '16:9',
          ]),
          _buildTableRow([
            'Splash',
            '1080 x 1920px',
            '5-10mb',
            'Mp4/Img',
            '9:16',
          ]),
          _buildTableRow([
            'Masthead',
            '1920 x 400px',
            '20-50mb',
            'Mp4/Img',
            '4:8:1',
          ]),
          _buildTableRow([
            'Overlays\nfor shorts',
            '1920 x 1080px',
            '500kb-1mb',
            'Png',
            '9:16',
          ]),
          _buildTableRow([
            'Landscape\nOverlays',
            '1920 x 1080px',
            '500kb-1mb',
            'Png',
            '16:9',
          ]),
          _buildTableRow([
            'Display for\nLandscape',
            '728 x 90px',
            '500kb-1mb',
            'Static\nImg',
            'Standard\nAB Size',
          ], isLast: true),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    List<String> cells, {
    bool isHeader = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildTableCell(cells[0], isHeader)),
          Expanded(flex: 3, child: _buildTableCell(cells[1], isHeader)),
          Expanded(flex: 2, child: _buildTableCell(cells[2], isHeader)),
          Expanded(flex: 2, child: _buildTableCell(cells[3], isHeader)),
          Expanded(flex: 2, child: _buildTableCell(cells[4], isHeader)),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHeader) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: isHeader ? 13.sp : 12.sp,
        color: isHeader ? Colors.black87 : Colors.grey[800],
        height: 1.2,
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () => Get.to(() => const CreateAdsCampaignStep2View()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Proceed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
