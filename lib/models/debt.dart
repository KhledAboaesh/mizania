enum DebtType { owedToMe, owedByMe }

class Debt {
  final String id;
  final String personOrInstitution;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final DebtType type;
  final String? note;
  final bool isPaid;

  Debt({
    required this.id,
    required this.personOrInstitution,
    required this.amount,
    required this.date,
    this.dueDate,
    required this.type,
    this.note,
    this.isPaid = false,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      personOrInstitution: json['personOrInstitution'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      type: json['type'] == 'owedToMe' ? DebtType.owedToMe : DebtType.owedByMe,
      note: json['note'],
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personOrInstitution': personOrInstitution,
      'amount': amount,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'type': type == DebtType.owedToMe ? 'owedToMe' : 'owedByMe',
      'note': note,
      'isPaid': isPaid,
    };
  }
}
