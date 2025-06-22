import 'package:expensify/models/transaction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'dart:math';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboardData ev,
    Emitter<DashboardState> emit,
  ) async {
    final box = Hive.box('transactions');
    final all = box.values
        .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
        .where((tx) => tx.userId == ev.userId)
        .toList();

    double totalIncome = 0, totalExpense = 0;
    Map<String, double> incomeByCategory = {}, expenseByCategory = {};
    Map<String, double> totalsByDate = {};
    Set<DateTime> distinctDays = {};

    double minTransaction = double.infinity,
        maxTransaction = double.negativeInfinity;
    double maxExpenseMonth = 0, maxExpenseWeek = 0;

    Map<int, double> monthlyExpenses = {}; // month -> amount
    Map<int, double> weeklyExpenses = {}; // week index -> amount
    Map<String, double> monthlyIncome = {};
    Map<String, double> monthlyExpense = {};

    for (var tx in all) {
      final amount = tx.amount;
      final date = tx.date;
      final dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      if (tx.type == 'Income') {
        totalIncome += amount;
        incomeByCategory[tx.category] =
            (incomeByCategory[tx.category] ?? 0) + amount;
      } else {
        totalExpense += amount;
        expenseByCategory[tx.category] =
            (expenseByCategory[tx.category] ?? 0) + amount;

        // Monthly expense
        final monthKey =
            "${date.year}-${date.month.toString().padLeft(2, '0')}";
        monthlyExpense[monthKey] = (monthlyExpense[monthKey] ?? 0) + amount;

        // Weekly expense (week number = day ~/ 7)
        int weekKey = (date.day - 1) ~/ 7;
        weeklyExpenses[weekKey] = (weeklyExpenses[weekKey] ?? 0) + amount;
      }

      // Common
      if (tx.type == 'Income') {
        final monthKey =
            "${date.year}-${date.month.toString().padLeft(2, '0')}";
        monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + amount;
      }

      totalsByDate[dateKey] =
          (totalsByDate[dateKey] ?? 0) +
          (tx.type == 'Income' ? amount : -amount);
      distinctDays.add(DateTime(date.year, date.month, date.day));
      minTransaction = min(minTransaction, amount);
      maxTransaction = max(maxTransaction, amount);
    }

    maxExpenseMonth = monthlyExpense.values.isEmpty
        ? 0
        : monthlyExpense.values.reduce(max);
    maxExpenseWeek = weeklyExpenses.values.isEmpty
        ? 0
        : weeklyExpenses.values.reduce(max);

    final int daysCount = distinctDays.isNotEmpty ? distinctDays.length : 1;
    final avgDailyIncome = totalIncome / daysCount;
    final avgDailyExpense = totalExpense / daysCount;

    emit(
      DashboardState(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        incomeByCategory: incomeByCategory,
        expenseByCategory: expenseByCategory,
        totalsByDate: totalsByDate,
        totalTransactions: all.length,
        incomeCount: all.where((t) => t.type == 'Income').length,
        expenseCount: all.where((t) => t.type == 'Expense').length,
        avgDailyIncome: avgDailyIncome,
        avgDailyExpense: avgDailyExpense,
        minTransaction: minTransaction == double.infinity ? 0 : minTransaction,
        maxTransaction: maxTransaction == double.negativeInfinity
            ? 0
            : maxTransaction,
        maxExpenseMonth: maxExpenseMonth,
        maxExpenseWeek: maxExpenseWeek,
        transactions: all,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
      ),
    );
  }
}
