import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../services/finance_provider.dart';
import '../models/debt.dart';

class DebtScreen extends StatelessWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final owedToMe =
        provider.debts.where((d) => d.type == DebtType.owedToMe).toList();
    final owedByMe =
        provider.debts.where((d) => d.type == DebtType.owedByMe).toList();

    final totalOwedToMe =
        owedToMe.where((d) => !d.isPaid).fold(0.0, (s, d) => s + d.amount);
    final totalOwedByMe =
        owedByMe.where((d) => !d.isPaid).fold(0.0, (s, d) => s + d.amount);

    return Scaffold(
      body: provider.debts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handshake_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('لا توجد ديون مسجلة',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('اضغط + لإضافة دين',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          title: 'لي على الآخرين',
                          amount: totalOwedToMe,
                          color: Colors.green,
                          icon: Icons.call_made,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryTile(
                          title: 'علي للآخرين',
                          amount: totalOwedByMe,
                          color: Colors.red,
                          icon: Icons.call_received,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: 'لي (${owedToMe.length})'),
                            Tab(text: 'علي (${owedByMe.length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _DebtList(debts: owedToMe),
                              _DebtList(debts: owedByMe),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDebtDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة دين'),
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddDebtSheet(),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '${amount.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtList extends StatelessWidget {
  final List<Debt> debts;
  const _DebtList({required this.debts});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    if (debts.isEmpty) {
      return Center(
          child: Text('لا يوجد', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (debt.isPaid
                      ? Colors.grey
                      : (debt.type == DebtType.owedToMe
                          ? Colors.green
                          : Colors.red))
                  .withOpacity(0.15),
              child: Icon(
                debt.isPaid
                    ? Icons.check_circle
                    : (debt.type == DebtType.owedToMe
                        ? Icons.call_made
                        : Icons.call_received),
                color: debt.isPaid
                    ? Colors.grey
                    : (debt.type == DebtType.owedToMe
                        ? Colors.green
                        : Colors.red),
              ),
            ),
            title: Text(
              debt.personOrInstitution,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: debt.isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (debt.note != null && debt.note!.isNotEmpty)
                  Text(debt.note!, style: const TextStyle(fontSize: 12)),
                Text(
                  DateFormat('yyyy/MM/dd').format(debt.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (debt.dueDate != null)
                  Text(
                    'الاستحقاق: ${DateFormat('yyyy/MM/dd').format(debt.dueDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          debt.dueDate!.isBefore(DateTime.now()) && !debt.isPaid
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${debt.amount.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: debt.isPaid
                        ? Colors.grey
                        : (debt.type == DebtType.owedToMe
                            ? Colors.green
                            : Colors.red),
                  ),
                ),
                Text(
                  debt.isPaid ? 'مسدد' : 'غير مسدد',
                  style: TextStyle(
                      fontSize: 11,
                      color: debt.isPaid ? Colors.green : Colors.orange),
                ),
              ],
            ),
            onTap: () => provider.toggleDebtStatus(debt.id),
            onLongPress: () => _confirmDelete(context, provider, debt.id),
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, FinanceProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الدين'),
        content: const Text('هل أنت متأكد من حذف هذا الدين؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              provider.deleteDebt(id);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Add Debt Sheet ────────────────────────────────────────────────────────────
class AddDebtSheet extends StatefulWidget {
  const AddDebtSheet({super.key});

  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet> {
  final _formKey = GlobalKey<FormState>();
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DebtType _type = DebtType.owedToMe;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final debt = Debt(
        id: const Uuid().v4(),
        personOrInstitution: _personController.text,
        amount: double.parse(_amountController.text),
        date: _date,
        dueDate: _dueDate,
        type: _type,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      provider.addDebt(debt);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إضافة دين جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Type selector
            SegmentedButton<DebtType>(
              segments: const [
                ButtonSegment(
                  value: DebtType.owedToMe,
                  label: Text('دين لي'),
                  icon: Icon(Icons.call_made),
                ),
                ButtonSegment(
                  value: DebtType.owedByMe,
                  label: Text('دين علي'),
                  icon: Icon(Icons.call_received),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _personController,
              decoration: const InputDecoration(
                labelText: 'اسم الشخص / الجهة',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ (ج.م)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  double.tryParse(v!) == null ? 'ادخل مبلغاً صحيحاً' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظة (اختياري)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 12),

            // Due date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(
                _dueDate == null
                    ? 'تاريخ الاستحقاق (اختياري)'
                    : 'الاستحقاق: ${DateFormat('yyyy/MM/dd').format(_dueDate!)}',
              ),
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _dueDate = null),
                    )
                  : null,
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('حفظ الدين', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
