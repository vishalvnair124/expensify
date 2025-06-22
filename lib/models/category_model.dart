//category_model.dart
class CategoryModel {
  final int userId; // Owner of the category
  final String name;
  final String type; // "Income" or "Expense"

  CategoryModel({required this.userId, required this.name, required this.type});

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'type': type,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    userId: json['userId'],
    name: json['name'],
    type: json['type'],
  );
}
