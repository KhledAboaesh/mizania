class Budget {
  final String category;
  final double limit;

  Budget({required this.category, required this.limit});

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'],
      limit: (json['limit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'limit': limit,
    };
  }
}
