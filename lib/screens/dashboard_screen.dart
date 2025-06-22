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
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, st) {
          if (st is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'Current Balance: ₹${st.currentBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: st.currentBalance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        buildRow(
                          "Total Income",
                          "₹${st.totalIncome.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Total Expense",
                          "₹${st.totalExpense.toStringAsFixed(2)}",
                        ),
                        const Divider(),
                        buildRow(
                          "Avg Monthly Income",
                          "₹${st.avgDailyIncome.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Avg Monthly Expense",
                          "₹${st.avgDailyExpense.toStringAsFixed(2)}",
                        ),
                        const Divider(),
                        buildRow(
                          "Total Transactions",
                          "${st.totalTransactions}",
                        ),
                        buildRow("Income Count", "${st.incomeCount}"),
                        buildRow("Expense Count", "${st.expenseCount}"),
                        const Divider(),
                        buildRow(
                          "Min Transaction",
                          "₹${st.minTransaction.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Max Transaction",
                          "₹${st.maxTransaction.toStringAsFixed(2)}",
                        ),
                        const Divider(),
                        buildRow(
                          "Max Expense (Month)",
                          "₹${st.maxExpenseMonth.toStringAsFixed(2)}",
                        ),
                        buildRow(
                          "Max Expense (Week)",
                          "₹${st.maxExpenseWeek.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Breakdown
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          "Income by Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...st.incomeByCategory.entries.map(
                          (e) =>
                              buildRow(e.key, "₹${e.value.toStringAsFixed(2)}"),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Expense by Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...st.expenseByCategory.entries.map(
                          (e) =>
                              buildRow(e.key, "₹${e.value.toStringAsFixed(2)}"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Totals by Date (for plotting charts)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Totals by Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
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
