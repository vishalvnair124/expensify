import 'package:expensify/blocs/dashboard/dashboard_bloc.dart';
import 'package:expensify/blocs/dashboard/dashboard_event.dart';
import 'package:expensify/blocs/dashboard/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedMonthKey;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData(widget.userId));
  }

  Widget buildStatCard(String title, String value, {Color? color}) {
    return Card(
      color: color ?? Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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

  List<Color> get colorList => [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
  ];

  List<PieChartSectionData> sectionsGenerate(
    Map<String, double> monthlyExpense,
  ) {
    final total = monthlyExpense.values.fold(0.0, (a, b) => a + b);
    final keys = monthlyExpense.keys.toList();

    return List.generate(monthlyExpense.length, (index) {
      final value = monthlyExpense[keys[index]]!;
      final percentage = (value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: colorList[index % colorList.length],
        value: value,
        title: "${value.toStringAsFixed(2)}\n($percentage%)",
        radius: 150,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, st) {
          if (st is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final months = st.monthlyExpenseByCategory.keys.toList()..sort();

          selectedMonthKey ??= months.isNotEmpty ? months.last : null;

          final expenseMap =
              st.monthlyExpenseByCategory[selectedMonthKey] ?? {};

          final incomeMap = st.monthlyIncomeByCategory[selectedMonthKey] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    borderOnForeground: true,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Current Balance: ₹${st.currentBalance.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: st.currentBalance >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent nested scroll
                      shrinkWrap: true, // Needed inside ScrollView
                      children: [
                        buildStatCard(
                          "Total Income",
                          "₹${st.totalIncome.toStringAsFixed(1)}",
                          color: Colors.green,
                        ),
                        buildStatCard(
                          "Total Expense",
                          "₹${st.totalExpense.toStringAsFixed(1)}",
                          color: Colors.red,
                        ),
                        buildStatCard(
                          "Avg Daily Income",
                          "₹${st.avgDailyIncome.toStringAsFixed(1)}",
                        ),
                        buildStatCard(
                          "Avg Daily Expense",
                          "₹${st.avgDailyExpense.toStringAsFixed(1)}",
                        ),
                      ],
                    ),
                  ),
                ),
                // Summary + Pie Chart
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
                          "Monthly Summary",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Month Dropdown
                        if (months.isNotEmpty)
                          Row(
                            children: [
                              const Text(
                                "Month:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: selectedMonthKey,
                                items: months
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedMonthKey = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Monthly Expense: $selectedMonthKey",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (expenseMap.isNotEmpty)
                          AspectRatio(
                            aspectRatio: 1.3,
                            child: PieChart(
                              PieChartData(
                                sections: sectionsGenerate(expenseMap),
                                sectionsSpace: 0,
                                centerSpaceRadius: 0,

                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text("No monthly expense data available."),
                          ),
                        const SizedBox(height: 16),

                        // Income
                        if (expenseMap.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 10,
                              children: List.generate(expenseMap.length, (
                                index,
                              ) {
                                final key = expenseMap.keys.toList()[index];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color:
                                          colorList[index % colorList.length],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(key),
                                  ],
                                );
                              }),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Divider(),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Monthly Income: $selectedMonthKey",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        if (incomeMap.isNotEmpty)
                          AspectRatio(
                            aspectRatio: 1.3,
                            child: PieChart(
                              PieChartData(
                                sections: sectionsGenerate(incomeMap),
                                sectionsSpace: 0,
                                centerSpaceRadius: 0,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text("No monthly income data available."),
                          ),
                        const SizedBox(height: 16),

                        // Legend
                        if (incomeMap.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 10,
                              children: List.generate(incomeMap.length, (
                                index,
                              ) {
                                final key = incomeMap.keys.toList()[index];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color:
                                          colorList[index % colorList.length],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(key),
                                  ],
                                );
                              }),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Divider(),
                        const SizedBox(height: 16),

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

                // Totals by Date
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
                          "Income by Date",
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
