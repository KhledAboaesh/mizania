import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/transaction.dart';
import '../services/finance_provider.dart';
import 'package:provider/provider.dart';

class TransactionDetailScreen extends StatelessWidget {
  final FinanceTransaction tx;
  const TransactionDetailScreen({super.key, required this.tx});

  String _categoryLabel(String? cat) {
    const map = {
      'food': '🍽️ طعام',
      'transportation': '🚌 مواصلات',
      'rent': '🏠 إيجار',
      'bills': '🧾 فواتير',
      'health': '🏥 صحة',
      'work': '💼 عمل',
      'other': '📦 أخرى',
    };
    return map[cat] ?? cat ?? 'غير محدد';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final dateStr = DateFormat('yyyy/MM/dd').format(tx.date);
    final timeStr = DateFormat('hh:mm a').format(tx.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العملية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (tx.imagePath != null && File(tx.imagePath!).existsSync())
              GestureDetector(
                onTap: () => _showFullImage(context),
                child: Hero(
                  tag: tx.id,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Image.file(
                      File(tx.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 120,
                color: color.withOpacity(0.1),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 60,
                  color: color.withOpacity(0.4),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          tx.title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text('ج.م',
                              style: TextStyle(color: color, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Details
                  _detailRow(Icons.label_outline, 'النوع',
                      isIncome ? 'دخل' : 'مصروف', color),
                  const SizedBox(height: 12),
                  _detailRow(Icons.category, 'الفئة',
                      _categoryLabel(tx.category), Colors.grey[700]!),
                  const SizedBox(height: 12),
                  _detailRow(Icons.calendar_today, 'التاريخ', dateStr,
                      Colors.grey[700]!),
                  const SizedBox(height: 12),
                  _detailRow(
                      Icons.access_time, 'الوقت', timeStr, Colors.grey[700]!),

                  if (tx.isRecurring) ...[
                    const SizedBox(height: 12),
                    _detailRow(
                        Icons.repeat, 'متكرر', 'نعم، شهرياً', Colors.purple),
                  ],

                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _detailRow(
                        Icons.note, 'ملاحظة', tx.note!, Colors.grey[700]!),
                  ],

                  if (tx.locationName != null) ...[
                    const SizedBox(height: 12),
                    _detailRow(Icons.location_on, 'الموقع', tx.locationName!,
                        Colors.teal),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),

                  // Image indicator
                  if (tx.imagePath != null && File(tx.imagePath!).existsSync())
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        onPressed: () => _showFullImage(context),
                        icon: const Icon(Icons.image),
                        label: const Text('عرض الصورة كاملة'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Hero(
              tag: tx.id,
              child: InteractiveViewer(
                child: Image.file(File(tx.imagePath!)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف العملية'),
        content: const Text('هل أنت متأكد من حذف هذه العملية؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Provider.of<FinanceProvider>(context, listen: false)
                  .deleteTransaction(tx.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
