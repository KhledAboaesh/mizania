import 'dart:convert';

enum TransactionType { income, expense }

enum IncomeSource { grant, work, gift, freelance, project, other }

enum ExpenseCategory {
  transportation,
  rent,
  bills,
  loan,
  food,
  health,
  entertainment,
  other,
}

class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? category; // Can be IncomeSource or ExpenseCategory name
  final String? note;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool isRecurring;
  final double? totalAmount; // For partial payments
  final double? remainingAmount;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.category,
    this.note,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.locationName,
    this.isRecurring = false,
    this.totalAmount,
    this.remainingAmount,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category'],
      note: json['note'],
      imagePath: json['imagePath'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      locationName: json['locationName'],
      isRecurring: json['isRecurring'] ?? false,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'note': note,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'isRecurring': isRecurring,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
    };
  }
}
