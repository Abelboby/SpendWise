class Income {
  final String id;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  double remainingAmount;

  Income({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.remainingAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'remainingAmount': remainingAmount,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      remainingAmount: json['remainingAmount'],
    );
  }
}
