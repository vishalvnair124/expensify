import 'package:expensify/blocs/dashboard/dashboard_bloc.dart';
import 'package:expensify/blocs/dashboard/dashboard_event.dart';
import 'package:expensify/blocs/dashboard/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({super.key, required this.userId});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData(widget.userId));
  }

  Widget buildRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(val, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, st) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        buildRow(
                          "Total Income",
                          "₹${st.totalIncome.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Total Expense",
                          "₹${st.totalExpense.toStringAsFixed(2)}",
                        ),
                        Divider(),
                        buildRow(
                          "Avg Daily Income",
                          "₹${st.avgDailyIncome.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Avg Daily Expense",
                          "₹${st.avgDailyExpense.toStringAsFixed(2)}",
                        ),
                        Divider(),
                        buildRow("Transactions", "${st.totalTransactions}"),
                        buildRow("Income count", "${st.incomeCount}"),
                        buildRow("Expense count", "${st.expenseCount}"),
                        Divider(),
                        buildRow(
                          "Min txn",
                          "₹${st.minTransaction.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Max txn",
                          "₹${st.maxTransaction.toStringAsFixed(2)}",
                        ),
                        Divider(),
                        buildRow(
                          "Max expense (month)",
                          "₹${st.maxExpenseMonth.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Max expense (week)",
                          "₹${st.maxExpenseWeek.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Category breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          "Income by Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...st.incomeByCategory.entries.map(
                          (e) =>
                              buildRow(e.key, "₹${e.value.toStringAsFixed(2)}"),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Expense by Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...st.expenseByCategory.entries.map(
                          (e) =>
                              buildRow(e.key, "₹${e.value.toStringAsFixed(2)}"),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Datewise totals
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          "Totals by Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...st.totalsByDate.entries.map(
                          (e) =>
                              buildRow(e.key, "₹${e.value.toStringAsFixed(2)}"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
