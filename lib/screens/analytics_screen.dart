import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/finance_provider.dart';
import '../models/transaction.dart';
import '../models/debt.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Balance summary ---
          _buildBalanceSummary(context, provider),
          const SizedBox(height: 20),

          // --- Pie chart ---
          if (provider.totalIncome > 0 || provider.totalExpense > 0) ...[
            _sectionTitle('مقارنة الدخل والمصاريف'),
            const SizedBox(height: 12),
            _buildPieChart(provider),
            const SizedBox(height: 20),
          ],

          // --- Category breakdown ---
          if (provider.totalExpense > 0) ...[
            _sectionTitle('تفاصيل المصاريف بالفئة'),
            const SizedBox(height: 12),
            _buildCategoryBreakdown(context, provider),
            const SizedBox(height: 20),
          ],

          // --- Debt summary ---
          _sectionTitle('ملخص الديون'),
          const SizedBox(height: 12),
          _buildDebtSummary(context, provider),
          const SizedBox(height: 20),

          // --- Stats rows ---
          _sectionTitle('إحصائيات سريعة'),
          const SizedBox(height: 12),
          _buildStatsGrid(context, provider),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBalanceSummary(BuildContext context, FinanceProvider p) {
    final balance = p.balance;
    final isPositive = balance >= 0;
    return Card(
      color: isPositive
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 40,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('صافي الرصيد', style: TextStyle(color: Colors.grey)),
                Text(
                  '${balance.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(FinanceProvider p) {
    final total = p.totalIncome + p.totalExpense;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: p.totalIncome,
                        title:
                            '${(p.totalIncome / total * 100).toStringAsFixed(0)}%',
                        color: Colors.green,
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: p.totalExpense,
                        title:
                            '${(p.totalExpense / total * 100).toStringAsFixed(0)}%',
                        color: Colors.red,
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendItem(Colors.green, 'الدخل', p.totalIncome),
                const SizedBox(height: 8),
                _legendItem(Colors.red, 'المصاريف', p.totalExpense),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, double amount) {
    return Row(
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('${amount.toStringAsFixed(0)} ج.م',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, FinanceProvider p) {
    final categories = {
      'food': ('طعام', Icons.restaurant, Colors.orange),
      'transportation': ('مواصلات', Icons.directions_bus, Colors.blue),
      'rent': ('إيجار', Icons.home, Colors.purple),
      'bills': ('فواتير', Icons.receipt_long, Colors.teal),
      'health': ('صحة', Icons.local_hospital, Colors.pink),
      'work': ('عمل', Icons.work, Colors.indigo),
      'other': ('أخرى', Icons.category, Colors.grey),
    };

    final items = categories.entries
        .map((e) {
          final spending = p.getCategorySpending(e.key);
          return (e.key, e.value.$1, e.value.$2, e.value.$3, spending);
        })
        .where((e) => e.$5 > 0)
        .toList()
      ..sort((a, b) => b.$5.compareTo(a.$5));

    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: items.map((item) {
            final pct = p.totalExpense > 0 ? item.$5 / p.totalExpense : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.$3, color: item.$4, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(item.$2,
                              style: const TextStyle(fontSize: 13))),
                      Text('${item.$5.toStringAsFixed(1)} ج.م',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.$4,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: item.$4,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDebtSummary(BuildContext context, FinanceProvider p) {
    final owedToMe = p.debts
        .where((d) => d.type == DebtType.owedToMe && !d.isPaid)
        .fold(0.0, (s, d) => s + d.amount);
    final owedByMe = p.debts
        .where((d) => d.type == DebtType.owedByMe && !d.isPaid)
        .fold(0.0, (s, d) => s + d.amount);
    final totalDebts = p.debts.length;
    final paidDebts = p.debts.where((d) => d.isPaid).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      _debtStatItem('لي على الآخرين', owedToMe, Colors.green),
                ),
                Container(
                    width: 1, height: 50, color: Colors.grey.withOpacity(0.3)),
                Expanded(
                  child: _debtStatItem('علي للآخرين', owedByMe, Colors.red),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('إجمالي الديون: $totalDebts',
                    style: const TextStyle(fontSize: 13)),
                Text('مسددة: $paidDebts',
                    style: const TextStyle(fontSize: 13, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtStatItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(1)} ج.م',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, FinanceProvider p) {
    final txCount = p.transactions.length;
    final avgExpense = txCount > 0
        ? p.transactions
                .where((t) => t.type == TransactionType.expense)
                .fold(0.0, (s, t) => s + t.amount) /
            (p.transactions
                .where((t) => t.type == TransactionType.expense)
                .length
                .clamp(1, 9999))
        : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _statCard(
            'عدد العمليات', txCount.toString(), Icons.list_alt, Colors.blue),
        _statCard('متوسط المصروف', '${avgExpense.toStringAsFixed(1)} ج.م',
            Icons.trending_flat, Colors.orange),
        _statCard('مواصلات', '${p.transportationTotal.toStringAsFixed(1)} ج.م',
            Icons.directions_bus, Colors.teal),
        _statCard(
            'متكررة شهرياً',
            '${p.monthlyRecurringTotal.toStringAsFixed(1)} ج.م',
            Icons.repeat,
            Colors.purple),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
