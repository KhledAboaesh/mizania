import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/debt.dart';
import '../models/budget.dart';
import '../services/json_storage_service.dart';

class FinanceProvider with ChangeNotifier {
  List<FinanceTransaction> _transactions = [];
  List<Debt> _debts = [];
  List<Budget> _budgets = [];

  List<FinanceTransaction> get transactions => [..._transactions];
  List<Debt> get debts => [..._debts];
  List<Budget> get budgets => [..._budgets];

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadData() async {
    final transData = await JsonStorageService.loadData('transactions');
    _transactions =
        transData.map((item) => FinanceTransaction.fromJson(item)).toList();

    final debtData = await JsonStorageService.loadData('debts');
    _debts = debtData.map((item) => Debt.fromJson(item)).toList();

    final budgetData = await JsonStorageService.loadData('budgets');
    _budgets = budgetData.map((item) => Budget.fromJson(item)).toList();

    notifyListeners();
  }

  Future<void> setBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.category == budget.category);
    if (index != -1) {
      _budgets[index] = budget;
    } else {
      _budgets.add(budget);
    }
    await JsonStorageService.saveData(
        'budgets', _budgets.map((b) => b.toJson()).toList());
    notifyListeners();
  }

  double getCategorySpending(String category) {
    return _transactions
        .where(
            (t) => t.type == TransactionType.expense && t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Budget? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    _transactions.add(transaction);
    await JsonStorageService.saveData(
      'transactions',
      _transactions.map((t) => t.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    await JsonStorageService.saveData(
      'debts',
      _debts.map((d) => d.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await JsonStorageService.saveData(
      'transactions',
      _transactions.map((t) => t.toJson()).toList(),
    );
    notifyListeners();
  }

  Future<void> toggleDebtStatus(String id) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index != -1) {
      final oldDebt = _debts[index];
      _debts[index] = Debt(
        id: oldDebt.id,
        personOrInstitution: oldDebt.personOrInstitution,
        amount: oldDebt.amount,
        date: oldDebt.date,
        dueDate: oldDebt.dueDate,
        type: oldDebt.type,
        note: oldDebt.note,
        isPaid: !oldDebt.isPaid,
      );
      await JsonStorageService.saveData(
          'debts', _debts.map((d) => d.toJson()).toList());
      notifyListeners();
    }
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    await JsonStorageService.saveData(
        'debts', _debts.map((d) => d.toJson()).toList());
    notifyListeners();
  }

  // Categories helper
  List<FinanceTransaction> getByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  // Monthly breakdown for Recurring Expenses
  double get monthlyRecurringTotal {
    return _transactions
        .where((t) => t.isRecurring)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Transportation costs
  double get transportationTotal {
    return _transactions
        .where((t) => t.category == 'transportation' || t.category == 'مواصلات')
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
