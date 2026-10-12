import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../values/api_constants.dart';

/// Helper to safely resolve and provide images, preventing URI errors, 404, and 502 crashes.
class ImageUtils {
  /// Safely resolves an image URL to an absolute URL or null.
  /// Handles relative paths (e.g. `/media/...`), whitespace, and invalid strings.
  static String? resolveUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      final domain = ApiConstants.baseUrl.replaceAll('/api/', '');
      return '$domain$trimmed';
    }

    return null;
  }

  /// Returns an [ImageProvider] that defaults to [fallbackAsset] if the URL is invalid.
  /// Intercepts network image errors with [errorListener] to prevent uncaught exceptions.
  static ImageProvider safeImageProvider(
    String? url, {
    String fallbackAsset = 'assets/images/user_avatar.png',
  }) {
    final resolved = resolveUrl(url);
    if (resolved != null) {
      return CachedNetworkImageProvider(
        resolved,
        errorListener: (_) {
          // Suppress 404 / 502 / network error trace from bubbling to console
        },
      );
    }
    return AssetImage(fallbackAsset);
  }

  /// Builds a [CircleAvatar] that suppresses unhandled network image errors (such as 404/502)
  /// and always falls back gracefully.
  static Widget safeCircleAvatar({
    required double radius,
    String? imageUrl,
    String fallbackAsset = 'assets/images/user_avatar.png',
    Color? backgroundColor,
    Widget? child,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      backgroundImage: safeImageProvider(imageUrl, fallbackAsset: fallbackAsset),
      onBackgroundImageError: (_, _) {
        // Suppress network image errors from printing stack traces
      },
      child: child,
    );
  }

  /// Safe widget for loading network images with placeholders and error fallbacks.
  static Widget safeNetworkImage({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    final resolved = resolveUrl(imageUrl);
    final fallback = errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(Icons.videocam, color: Colors.white54, size: 40),
          ),
        );

    if (resolved == null) {
      return borderRadius != null
          ? ClipRRect(borderRadius: borderRadius, child: fallback)
          : fallback;
    }

    Widget img = CachedNetworkImage(
      imageUrl: resolved,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade900,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
      errorWidget: (context, url, error) => fallback,
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: img);
    }
    return img;
  }
}
