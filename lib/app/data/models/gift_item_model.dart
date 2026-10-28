import 'package:flutter/material.dart';

class GiftItem {
  final String code;
  final String name;
  final String category;
  final int coins;
  final String icon;
  final Color categoryColor;
  final List<Color> gradientColors;

  /// Optional: path to an SVG asset, e.g. 'assets/svg/GT001_Appreciation-Bloom.svg'.
  /// When provided the gift gallery renders the SVG instead of the emoji [icon].
  final String? svgAsset;

  const GiftItem({
    required this.code,
    required this.name,
    required this.category,
    required this.coins,
    required this.icon,
    required this.categoryColor,
    required this.gradientColors,
    this.svgAsset,
  });

  String get formattedCoins {
    if (coins >= 1000000) {
      final val = coins / 1000000;
      return val == val.roundToDouble() ? '${val.toInt()}M' : '${val.toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      final val = coins / 1000;
      return val == val.roundToDouble() ? '${val.toInt()}K' : '${val.toStringAsFixed(1)}K';
    }
    return coins.toString();
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'category': category,
    'coins': coins,
    'icon': icon,
  };
}
