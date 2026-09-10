class ShopItem {
  final int? id;
  final String title;
  final String price;
  final String? originalPrice;
  final String imageUrl;
  final String category;
  final double priceValue;
  final double? originalPriceValue;
  final String? county;
  final String? city;

  ShopItem({
    this.id,
    required this.title,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.priceValue,
    this.originalPriceValue,
    this.county,
    this.city,
  });
}
