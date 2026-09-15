import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glotune/app/core/values/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String creator;
  final String views;
  final String time;
  final String duration;
  final String thumbnailUrl;
  final String creatorAvatarUrl;

  final VoidCallback? onMorePressed;
  final VoidCallback? onAvatarTap;

  const VideoCard({
    super.key,
    required this.title,
    required this.creator,
    required this.views,
    required this.time,
    required this.duration,
    required this.thumbnailUrl,
    required this.creatorAvatarUrl,
    this.onMorePressed,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thumbnail
        Stack(
          children: [
            Container(
              height: 210.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                image: thumbnailUrl.isNotEmpty
                    ? DecorationImage(
                        image: thumbnailUrl.startsWith('http')
                            ? CachedNetworkImageProvider(thumbnailUrl)
                                  as ImageProvider
                            : AssetImage(thumbnailUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: thumbnailUrl.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white54,
                        size: 48.sp,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Details
        Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: creatorAvatarUrl.isNotEmpty
                      ? (creatorAvatarUrl.startsWith('http')
                            ? CachedNetworkImageProvider(creatorAvatarUrl)
                                  as ImageProvider
                            : AssetImage(creatorAvatarUrl) as ImageProvider)
                      : null,
                  child: creatorAvatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.white, size: 24.sp)
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "$creator • $views • $time",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMorePressed,
                icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
