//transaction_model.dart
class TransactionModel {
  final int userId;
  final double amount;
  final String type; // "Income" or "Expense"
  final String category; // Name of category
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'amount': amount,
    'type': type,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        userId: json['userId'],
        amount: json['amount'],
        type: json['type'],
        category: json['category'],
        date: DateTime.parse(json['date']),
        note: json['note'],
      );
}
