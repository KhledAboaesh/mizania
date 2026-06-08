import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/finance_provider.dart';
import '../models/transaction.dart';
import '../widgets/summary_card.dart';
import 'debt_screen.dart';
import 'analytics_screen.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';
import 'team_screen.dart';
import 'settings_screen.dart';
import '../services/data_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const DebtScreen(),
    const AnalyticsScreen(),
    const TeamScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 30,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.account_balance_wallet),
            ),
            const SizedBox(width: 10),
            const Text('ميزانية'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => DataService.exportData(),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'الديون'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'التحليلات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'الفريق',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'الرصيد المتاح',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.balance.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SummaryCard(
                title: 'الدخل',
                amount: provider.totalIncome.toStringAsFixed(2),
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              SummaryCard(
                title: 'المصاريف',
                amount: provider.totalExpense.toStringAsFixed(2),
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallStat(
                  context,
                  'المواصلات',
                  provider.transportationTotal.toStringAsFixed(2),
                  Icons.directions_bus,
                  Colors.orange),
              const SizedBox(width: 8),
              _buildSmallStat(
                  context,
                  'ثابت شهري',
                  provider.monthlyRecurringTotal.toStringAsFixed(2),
                  Icons.repeat,
                  Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'أحدث العمليات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (provider.transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('لا توجد عمليات مسجلة بعد'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.transactions.length > 5
                  ? 5
                  : provider.transactions.length,
              itemBuilder: (context, index) {
                final tx = provider.transactions.reversed.toList()[index];
                final dateStr = DateFormat('yyyy/MM/dd').format(tx.date);
                final timeStr = DateFormat('hh:mm a').format(tx.date);
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.type == TransactionType.income
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      child: Icon(
                        tx.type == TransactionType.income
                            ? Icons.add
                            : Icons.remove,
                        color: tx.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(tx.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Row(children: [
                      const Icon(Icons.calendar_today,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('$dateStr  ', style: const TextStyle(fontSize: 11)),
                      const Icon(Icons.access_time,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(timeStr, style: const TextStyle(fontSize: 11)),
                      if (tx.imagePath != null)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child:
                              Icon(Icons.image, size: 13, color: Colors.blue),
                        ),
                    ]),
                    trailing: Text(
                      '${tx.type == TransactionType.income ? "+" : "-"}${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: tx.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(tx: tx),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(BuildContext context, String title, String amount,
      IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(amount,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
