import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:glotune/app/core/constants/gift_catalogue.dart';
import 'package:glotune/app/data/models/gift_item_model.dart';
import 'package:glotune/app/routes/app_pages.dart';

class GiftGallerySheet extends StatefulWidget {
  final int userCoins;
  final String? recipientName;
  final Future<void> Function(GiftItem gift, int quantity) onSend;

  const GiftGallerySheet({
    super.key,
    required this.userCoins,
    this.recipientName,
    required this.onSend,
  });

  static Future<void> show({
    required BuildContext context,
    int userCoins = 0,
    String? recipientName,
    required Future<void> Function(GiftItem gift, int quantity) onSend,
  }) {
    return Get.bottomSheet<void>(
      GiftGallerySheet(
        userCoins: userCoins,
        recipientName: recipientName,
        onSend: onSend,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  State<GiftGallerySheet> createState() => _GiftGallerySheetState();
}

class _GiftGallerySheetState extends State<GiftGallerySheet> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late GiftItem _selectedGift;
  int _selectedQuantity = 1;
  bool _isSending = false;
  final TextEditingController _searchController = TextEditingController();

  final List<int> _presetQuantities = [1, 5, 10, 99];

  @override
  void initState() {
    super.initState();
    _selectedGift = GiftCatalogue.allGifts.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GiftItem> get _filteredGifts {
    return GiftCatalogue.search(_searchQuery, category: _selectedCategory);
  }

  int _getCountForCategory(String cat) {
    return GiftCatalogue.getByCategory(cat).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredGifts;
    final totalCost = _selectedGift.coins * _selectedQuantity;

    return Container(
      height: 0.82.sh,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          SizedBox(height: 10.h),
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Header: Logo & Title + Balance + Close
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Title and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFF4081), Color(0xFFFFD54F)],
                            ).createShader(bounds),
                            child: Text(
                              GiftCatalogue.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "70 Gifts",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.recipientName != null
                            ? "Send to @${widget.recipientName} • Small Gifts, Big Moments!"
                            : "Small Gifts, Big Moments • Initial Catalogue",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Coins Balance Pill
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.MAKE_DONATION);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          widget.userCoins > 0 ? "${widget.userCoins}" : "Recharge",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.add_circle, color: Colors.amberAccent, size: 13.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 6.w),

                // Close Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Search Box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white, fontSize: 11.5.sp),
                decoration: InputDecoration(
                  hintText: "Search gifts by name or code (e.g. GT001, Dragon)...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 10.5.sp),
                  prefixIcon: Icon(Icons.search, color: Colors.white54, size: 16.sp),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white54, size: 14.sp),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Category Chips Bar (Horizontal Scrollable)
          SizedBox(
            height: 32.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              itemCount: GiftCatalogue.categories.length,
              separatorBuilder: (_, _) => SizedBox(width: 6.w),
              itemBuilder: (context, idx) {
                final cat = GiftCatalogue.categories[idx];
                final isSelected = _selectedCategory == cat;
                final count = _getCountForCategory(cat);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFE50914), Color(0xFF8B0000)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? Colors.redAccent : Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 10.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black26 : Colors.white10,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "$count",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 6.h),

          // Gift Grid (Scrollable)
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.card_giftcard_outlined, color: Colors.white24, size: 42.sp),
                        SizedBox(height: 8.h),
                        Text(
                          "No gifts found for '$_searchQuery'",
                          style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 0.76,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final gift = filtered[idx];
                      final isSelected = _selectedGift.code == gift.code;

                      return _buildGiftCard(gift, isSelected);
                    },
                  ),
          ),

          // Bottom Send & Quantity Control Panel
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF161626),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Selected Gift Info + Quantity Presets
                  Row(
                    children: [
                      // Selected Gift Preview
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: _selectedGift.gradientColors),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _selectedGift.svgAsset != null
                            ? SvgPicture.asset(
                                _selectedGift.svgAsset!,
                                width: 22.w,
                                height: 22.w,
                                fit: BoxFit.contain,
                              )
                            : Text(
                                _selectedGift.icon,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${_selectedGift.code} • ${_selectedGift.name}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.amber, size: 11),
                                SizedBox(width: 3.w),
                                Text(
                                  "${_selectedGift.formattedCoins} Coins each",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Quantity Preset Chips
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _presetQuantities.map((qty) {
                          final isQtySelected = _selectedQuantity == qty;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedQuantity = qty;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 4.w),
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isQtySelected
                                    ? Colors.amber.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isQtySelected ? Colors.amber : Colors.white12,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "${qty}x",
                                style: TextStyle(
                                  color: isQtySelected ? Colors.amber : Colors.white70,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Row 2: Total Calculation & Send Button
                  Row(
                    children: [
                      // Total cost
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total Cost",
                            style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                              SizedBox(width: 3.w),
                              Text(
                                "$totalCost Coins",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 14.w),

                      // Send Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 4,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: _isSending
                              ? null
                              : () async {
                                  setState(() {
                                    _isSending = true;
                                  });
                                  try {
                                    await widget.onSend(_selectedGift, _selectedQuantity);
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSending = false;
                                      });
                                    }
                                  }
                                },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE50914), Color(0xFFFF5252), Color(0xFFE91E63)],
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: _isSending
                                  ? SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, color: Colors.white, size: 15.sp),
                                        SizedBox(width: 6.w),
                                        Text(
                                          "Send ${_selectedQuantity > 1 ? '($_selectedQuantity)' : ''}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftCard(GiftItem gift, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGift = gift;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: isSelected
              ? gift.categoryColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? gift.categoryColor : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.8 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gift.categoryColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Code & Checkmark row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    gift.code,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: gift.categoryColor, size: 10.sp)
                else
                  SizedBox(width: 10.sp),
              ],
            ),
            SizedBox(height: 3.h),

            // Icon thumbnail (no background)
            Expanded(
              child: Center(
                child: gift.svgAsset != null
                    ? SvgPicture.asset(
                        gift.svgAsset!,
                        width: 44.w,
                        height: 44.w,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        gift.icon,
                        style: TextStyle(fontSize: 28.sp),
                      ),
              ),
            ),
            SizedBox(height: 2.h),

            // Gift Name
            Text(
              gift.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),

            // Coins Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 9.sp),
                SizedBox(width: 2.w),
                Text(
                  gift.formattedCoins,
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
