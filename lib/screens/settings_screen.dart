import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/finance_provider.dart';
import '../services/pdf_service.dart';
import 'budget_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تبديل بين الثيم الفاتح والمظلم'),
            secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          ListTile(
            title: const Text('إدارة الميزانيات'),
            subtitle: const Text('تحديد حدود الصرف لكل فئة'),
            leading: const Icon(Icons.account_balance_wallet),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BudgetScreen())),
          ),
          ListTile(
            title: const Text('تصدير تقرير PDF'),
            subtitle: const Text('توليد تقرير شامل بكافة العمليات'),
            leading: const Icon(Icons.picture_as_pdf),
            onTap: () =>
                PdfService.generateReport(financeProvider.transactions),
          ),
          const Divider(),
          ListTile(
            title: const Text('اسم التطبيق'),
            subtitle: const Text('ميزانية - الاصدار 2.0'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
