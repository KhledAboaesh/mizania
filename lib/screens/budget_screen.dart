import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/finance_provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final categories = ExpenseCategory.values.map((e) => e.name).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الميزانيات')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final budget = provider.getBudgetForCategory(cat);
          final spending = provider.getCategorySpending(cat);
          final percent =
              budget != null ? (spending / budget.limit).clamp(0.0, 1.0) : 0.0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditBudget(
                            context, provider, cat, budget?.limit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey[300],
                    color: percent > 0.9 ? Colors.red : Colors.green,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المنفق: ${spending.toStringAsFixed(2)} ج.م'),
                      Text(
                          'الحد: ${budget?.limit.toStringAsFixed(2) ?? "غير محدد"} ج.م'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditBudget(BuildContext context, FinanceProvider provider,
      String cat, double? currentLimit) {
    final controller =
        TextEditingController(text: currentLimit?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل ميزانية $cat'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'الحد الأقصى (ج.م)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(controller.text) ?? 0.0;
              provider.setBudget(Budget(category: cat, limit: limit));
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
