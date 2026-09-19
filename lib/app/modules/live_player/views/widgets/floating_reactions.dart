import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  void initState() {
    super.initState();
    _sub = widget.reactionStream.listen((reactionType) {
      print("[FloatingReactions] Received reaction: $reactionType");
      _addReaction(reactionType);
    });
  }

  void _addReaction(String type) {
    if (!mounted) return;
    
    IconData iconData = Icons.thumb_up;
    Color color = Colors.blue;
    
    if (type == 'heart' || type == 'love') {
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
      controller: controller,
      startX: _random.nextDouble() * 50 - 25, // offset from center
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
        children: _reactions.map((item) {
          return AnimatedBuilder(
            animation: item.controller,
            builder: (context, child) {
              final value = item.controller.value;
              final yOffset = -value * 280.h; // Float up 280 pixels
              final xOffset = item.startX + (sin(value * pi * 2) * 24); // Sway side to side
              final opacity = (1.0 - value).clamp(0.0, 1.0); // Fade out

              return Positioned(
                bottom: 90.h,
                right: 36.w + xOffset, // Origin point directly above the reaction buttons
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, yOffset),
                    child: Transform.scale(
                      scale: 1.0 + (value * 0.6), // Grow dynamically
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
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 36.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionItem {
  final String id;
  final String type;
  final IconData icon;
  final Color color;
  final AnimationController controller;
  final double startX;

  _ReactionItem({
    required this.id,
    required this.type,
    required this.icon,
    required this.color,
    required this.controller,
    required this.startX,
  });
}
