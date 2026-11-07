import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:glotune/app/core/constants/gift_catalogue.dart';
import 'package:glotune/app/data/models/gift_item_model.dart';

class FloatingReactions extends StatefulWidget {
  final Stream<String> reactionStream;

  const FloatingReactions({super.key, required this.reactionStream});

  @override
  State<FloatingReactions> createState() => _FloatingReactionsState();
}

class _FloatingReactionsState extends State<FloatingReactions> with TickerProviderStateMixin {
  final List<_ReactionItem> _reactions = [];
  final Random _random = Random();
  StreamSubscription<String>? _sub;

  // Video Gift Popup State
  VideoPlayerController? _videoPlayerController;
  _ActiveGiftVideo? _activeVideo;
  final List<_ActiveGiftVideo> _videoQueue = [];
  AnimationController? _videoAnimController;
  Timer? _videoSafetyTimer;
  DateTime? _lastVideoTime;
  String? _lastVideoIdentifier;

  @override
  void initState() {
    super.initState();
    _sub = widget.reactionStream.listen((reactionType) {
      print("[FloatingReactions] Received reaction: $reactionType");

      // Check if this reaction has an animated video asset
      final videoAsset = GiftCatalogue.getVideoAsset(reactionType);
      if (videoAsset != null) {
        _triggerGiftVideo(reactionType, videoAsset);
      }

      _addReaction(reactionType);
    });
  }

  void _triggerGiftVideo(String identifier, String videoAsset) {
    if (!mounted) return;

    // Debounce duplicate socket triggers for the same gift within 1.5 seconds
    final now = DateTime.now();
    if (_lastVideoIdentifier == identifier &&
        _lastVideoTime != null &&
        now.difference(_lastVideoTime!) < const Duration(milliseconds: 1500)) {
      print("[FloatingReactions] Debouncing duplicate video trigger for: $identifier");
      return;
    }
    _lastVideoIdentifier = identifier;
    _lastVideoTime = now;

    final giftItem = GiftCatalogue.find(identifier);
    final item = _ActiveGiftVideo(
      giftIdentifier: identifier,
      videoAsset: videoAsset,
      giftItem: giftItem,
    );

    if (_activeVideo != null) {
      if (_videoQueue.length < 3) {
        _videoQueue.add(item);
      }
      return;
    }

    _playVideoItem(item);
  }

  Future<void> _playVideoItem(_ActiveGiftVideo item) async {
    if (!mounted) return;

    _videoSafetyTimer?.cancel();
    _videoSafetyTimer = null;

    // Dispose old controller
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;

    setState(() {
      _activeVideo = item;
    });

    _videoAnimController?.dispose();
    _videoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    try {
      final controller = VideoPlayerController.asset(item.videoAsset);
      await controller.initialize();

      if (!mounted || _activeVideo != item) {
        await controller.dispose();
        return;
      }

      _videoPlayerController = controller;
      await controller.setVolume(1.0);
      await controller.play();

      _videoAnimController?.forward();
      setState(() {});

      final duration = controller.value.duration;
      final playDuration = (duration > Duration.zero)
          ? duration
          : const Duration(seconds: 4);

      // Listener for video completion
      void checkCompletion() {
        if (!mounted || _videoPlayerController != controller) return;
        if (controller.value.isInitialized &&
            controller.value.position >= duration &&
            duration > Duration.zero) {
          controller.removeListener(checkCompletion);
          _finishVideoItem();
        }
      }

      controller.addListener(checkCompletion);

      // Safety timeout: video duration + 500ms (clamped between 3s and 7s)
      final safetyMs = (playDuration.inMilliseconds + 500).clamp(3000, 7000);
      _videoSafetyTimer = Timer(Duration(milliseconds: safetyMs), () {
        _finishVideoItem();
      });
    } catch (e) {
      print("[FloatingReactions] Video playback error for ${item.videoAsset}: $e");
      // Fallback: show the gift in a popup for 3 seconds then close
      _videoAnimController?.forward();
      setState(() {});
      _videoSafetyTimer = Timer(const Duration(milliseconds: 3000), () {
        _finishVideoItem();
      });
    }
  }

  void _finishVideoItem() {
    if (!mounted || _activeVideo == null) return;

    _videoSafetyTimer?.cancel();
    _videoSafetyTimer = null;

    // Animate exit (scale down and fade out)
    if (_videoAnimController != null) {
      _videoAnimController!.reverse().then((_) async {
        if (!mounted) return;
        await _videoPlayerController?.dispose();
        _videoPlayerController = null;

        setState(() {
          _activeVideo = null;
        });

        // Play next video in queue if any
        if (_videoQueue.isNotEmpty) {
          final next = _videoQueue.removeAt(0);
          _playVideoItem(next);
        }
      });
    } else {
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
      setState(() {
        _activeVideo = null;
      });
    }
  }

  void _addReaction(String type) {
    if (!mounted) return;
    
    IconData iconData = Icons.favorite;
    Color color = Colors.redAccent;
    String? svgAsset;
    String? emoji;

    final gift = GiftCatalogue.find(type);
    if (gift != null) {
      svgAsset = gift.svgAsset;
      emoji = gift.icon;
      color = gift.categoryColor;
    } else if (type == 'heart' || type == 'love') {
      iconData = Icons.favorite;
      color = Colors.red;
    } else if (type == 'like') {
      iconData = Icons.thumb_up;
      color = Colors.blue;
    } else if (type == 'share') {
      iconData = Icons.share;
      color = Colors.green;
    } else if (type == 'laugh') {
      iconData = Icons.sentiment_very_satisfied;
      color = Colors.orange;
    } else if (type == 'rose') {
      iconData = Icons.local_florist;
      color = Colors.pink;
    } else if (type == 'diamond') {
      iconData = Icons.diamond;
      color = Colors.lightBlueAccent;
    } else if (type == 'crown') {
      iconData = Icons.workspace_premium;
      color = Colors.amber;
    } else {
      iconData = Icons.favorite;
      color = Colors.redAccent;
    }

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final item = _ReactionItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      icon: iconData,
      color: color,
      svgAsset: svgAsset,
      emoji: emoji,
      controller: controller,
      startX: _random.nextDouble() * 50 - 25,
    );

    setState(() {
      _reactions.add(item);
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _reactions.remove(item);
        });
      }
      controller.dispose();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _videoSafetyTimer?.cancel();
    _videoAnimController?.dispose();
    _videoPlayerController?.dispose();
    for (var item in _reactions) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Floating small reactions on the bottom right
          ..._reactions.map((item) {
            return AnimatedBuilder(
              animation: item.controller,
              builder: (context, child) {
                final value = item.controller.value;
                final yOffset = -value * 280.h;
                final xOffset = item.startX + (sin(value * pi * 2) * 24);
                final opacity = (1.0 - value).clamp(0.0, 1.0);

                return Positioned(
                  bottom: 90.h,
                  right: 36.w + xOffset,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: 1.0 + (value * 0.6),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: item.svgAsset != null
                              ? SvgPicture.asset(
                                  item.svgAsset!,
                                  width: 38.w,
                                  height: 38.w,
                                  fit: BoxFit.contain,
                                )
                              : (item.emoji != null
                                  ? Text(
                                      item.emoji!,
                                      style: TextStyle(fontSize: 32.sp),
                                    )
                                  : Icon(
                                      item.icon,
                                      color: item.color,
                                      size: 36.sp,
                                    )),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // 2. Full Screen Video Gift Animation Overlay
          if (_activeVideo != null && _videoAnimController != null)
            Positioned.fill(
              child: FadeTransition(
                opacity: _videoAnimController!,
                child: _buildVideoPopupCard(_activeVideo!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPopupCard(_ActiveGiftVideo item) {
    final gift = item.giftItem;
    final giftName = gift?.name ?? item.giftIdentifier;
    final coinsStr = gift != null ? "${gift.formattedCoins} Coins" : "";
    final hasController = _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        // Video scaled and fitted to screen cleanly
        if (hasController)
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio > 0
                  ? _videoPlayerController!.value.aspectRatio
                  : (16 / 9),
              child: VideoPlayer(_videoPlayerController!),
            ),
          )
        else if (gift?.svgAsset != null)
          Center(
            child: SvgPicture.asset(
              gift!.svgAsset!,
              width: 240.w,
              height: 240.w,
              fit: BoxFit.contain,
            ),
          )
        else if (gift != null)
          Center(
            child: Text(gift.icon, style: TextStyle(fontSize: 100.sp)),
          ),

        // Glowing Banner at bottom area with Gift Name and Coins
        Positioned(
          bottom: 120.h,
          left: 20.w,
          right: 20.w,
          child: Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _videoAnimController!,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gift?.gradientColors ??
                        [const Color(0xFFE50914), const Color(0xFFE91E63)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: (gift?.categoryColor ?? Colors.amber).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "✨ $giftName ✨",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (coinsStr.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 12),
                            SizedBox(width: 3.w),
                            Text(
                              coinsStr,
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveGiftVideo {
  final String giftIdentifier;
  final String videoAsset;
  final GiftItem? giftItem;

  _ActiveGiftVideo({
    required this.giftIdentifier,
    required this.videoAsset,
    this.giftItem,
  });
}

class _ReactionItem {
  final String id;
  final String type;
  final IconData icon;
  final Color color;
  final String? svgAsset;
  final String? emoji;
  final AnimationController controller;
  final double startX;

  _ReactionItem({
    required this.id,
    required this.type,
    required this.icon,
    required this.color,
    this.svgAsset,
    this.emoji,
    required this.controller,
    required this.startX,
  });
}
