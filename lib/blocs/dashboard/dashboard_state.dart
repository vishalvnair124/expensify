import 'package:expensify/models/transaction_model.dart';

class DashboardState {
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expenseByCategory;
  final Map<String, double> totalsByDate;

  final int totalTransactions;
  final int incomeCount;
  final int expenseCount;
  final double avgDailyIncome;
  final double avgDailyExpense;
  final double minTransaction;
  final double maxTransaction;
  final double maxExpenseMonth;
  final double maxExpenseWeek;
  final List<TransactionModel> transactions;

  final Map<String, double> monthlyIncome; // NEW
  final Map<String, double> monthlyExpense; // NEW

  DashboardState({
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeByCategory,
    required this.expenseByCategory,
    required this.totalsByDate,
    required this.totalTransactions,
    required this.incomeCount,
    required this.expenseCount,
    required this.avgDailyIncome,
    required this.avgDailyExpense,
    required this.minTransaction,
    required this.maxTransaction,
    required this.maxExpenseMonth,
    required this.maxExpenseWeek,
    required this.transactions,
    required this.monthlyIncome, // NEW
    required this.monthlyExpense, // NEW
  });
}

class DashboardInitial extends DashboardState {
  DashboardInitial()
    : super(
        totalIncome: 0,
        totalExpense: 0,
        incomeByCategory: {},
        expenseByCategory: {},
        totalsByDate: {},
        totalTransactions: 0,
        incomeCount: 0,
        expenseCount: 0,
        avgDailyIncome: 0,
        avgDailyExpense: 0,
        minTransaction: 0,
        maxTransaction: 0,
        maxExpenseMonth: 0,
        maxExpenseWeek: 0,
        transactions: [],
        monthlyIncome: {}, // NEW
        monthlyExpense: {}, // NEW
      );
}
