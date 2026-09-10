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

  @override
  void initState() {
    super.initState();
    widget.reactionStream.listen((reactionType) {
      _addReaction(reactionType);
    });
  }

  void _addReaction(String type) {
    if (!mounted) return;
    
    IconData iconData = Icons.thumb_up;
    Color color = Colors.blue;
    
    if (type == 'heart') {
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
    }

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final item = _ReactionItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      icon: iconData,
      color: color,
      controller: controller,
      startX: _random.nextDouble() * 40 - 20, // offset from center
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
    for (var item in _reactions) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _reactions.map((item) {
          return AnimatedBuilder(
            animation: item.controller,
            builder: (context, child) {
              final value = item.controller.value;
              final yOffset = -value * 200.h; // Float up 200 pixels
              final xOffset = item.startX + (sin(value * pi * 2) * 20); // Sway side to side
              final opacity = 1.0 - value; // Fade out

              return Positioned(
                bottom: 80.h,
                right: 60.w + xOffset, // Origin point near the bottom right
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, yOffset),
                    child: Transform.scale(
                      scale: 1.0 + (value * 0.5), // Grow slightly
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 32.sp,
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
