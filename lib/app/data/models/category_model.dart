class CategoryModel {
  final int id;
  final String name;
  final int? subCategory;

  CategoryModel({
    required this.id,
    required this.name,
    this.subCategory,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      subCategory: json['sub_category'] as int?,
    );
  }
}
