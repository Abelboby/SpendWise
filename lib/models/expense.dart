class Expense {
  final String id;
  final String incomeId;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.incomeId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incomeId': incomeId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      incomeId: json['incomeId'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}
