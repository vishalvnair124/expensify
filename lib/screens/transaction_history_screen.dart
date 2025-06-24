import 'package:expensify/blocs/transaction/transaction_bloc.dart';
import 'package:expensify/blocs/transaction/transaction_event.dart';
import 'package:expensify/blocs/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int userId;

  const TransactionHistoryScreen({super.key, required this.userId});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? selectedType;
  String sortOption = 'Date Descending';
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                if (state is TransactionError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransactionLoaded) {
                  List<TransactionModel> txs = state.transactions
                      .where((tx) => tx.userId == widget.userId)
                      .toList();

                  // Apply Type Filter
                  if (selectedType != null) {
                    txs = txs.where((tx) => tx.type == selectedType).toList();
                  }

                  // Apply Date Range Filter
                  if (selectedRange != null) {
                    txs = txs.where((tx) {
                      return tx.date.isAfter(
                            selectedRange!.start.subtract(
                              const Duration(days: 1),
                            ),
                          ) &&
                          tx.date.isBefore(
                            selectedRange!.end.add(const Duration(days: 1)),
                          );
                    }).toList();
                  }

                  // Apply Sorting
                  switch (sortOption) {
                    case 'Amount Ascending':
                      txs.sort((a, b) => a.amount.compareTo(b.amount));
                      break;
                    case 'Amount Descending':
                      txs.sort((a, b) => b.amount.compareTo(a.amount));
                      break;
                    case 'Date Ascending':
                      txs.sort((a, b) => a.date.compareTo(b.date));
                      break;
                    case 'Date Descending':
                    default:
                      txs.sort((a, b) => b.date.compareTo(a.date));
                      break;
                  }

                  if (txs.isEmpty) {
                    return const Center(child: Text("No Transactions Found"));
                  }

                  final grouped = _groupByDate(txs);

                  return ListView(
                    children: grouped.entries.map((entry) {
                      final date = entry.key;
                      final items = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.indigo.shade100,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...items.map(
                            (tx) => _buildTransactionTile(context, tx),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(
                    child: Text("Failed to load transactions."),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            DropdownButton<String>(
              value: selectedType,
              hint: const Text("Type"),
              items: const [
                DropdownMenuItem(value: 'Income', child: Text("Income")),
                DropdownMenuItem(value: 'Expense', child: Text("Expense")),
              ],
              onChanged: (val) => setState(() => selectedType = val),
            ),
            DropdownButton<String>(
              value: sortOption,
              items: const [
                DropdownMenuItem(
                  value: 'Date Descending',
                  child: Text("Date ↓"),
                ),
                DropdownMenuItem(
                  value: 'Date Ascending',
                  child: Text("Date ↑"),
                ),
                DropdownMenuItem(
                  value: 'Amount Ascending',
                  child: Text("Amount ↑"),
                ),
                DropdownMenuItem(
                  value: 'Amount Descending',
                  child: Text("Amount ↓"),
                ),
              ],
              onChanged: (val) => setState(() => sortOption = val!),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                selectedRange == null
                    ? "Pick Date Range"
                    : "${DateFormat.yMd().format(selectedRange!.start)} - ${DateFormat.yMd().format(selectedRange!.end)}",
              ),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => selectedRange = picked);
                }
              },
            ),
            TextButton(
              onPressed: () => setState(() {
                selectedType = null;
                selectedRange = null;
                sortOption = 'Date Descending';
              }),
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel tx) {
    return ListTile(
      title: Text(
        tx.category,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(tx.note ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${tx.type == 'Income' ? '+' : '-'} ₹${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: tx.type == 'Income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditDialog(context, tx),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () =>
                context.read<TransactionBloc>().add(DeleteTransaction(tx)),
          ),
        ],
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txs) {
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in txs) {
      final key = DateFormat.yMMMMd().format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    return grouped;
  }

  void _showEditDialog(BuildContext context, TransactionModel tx) {
    final amountController = TextEditingController(text: tx.amount.toString());
    final noteController = TextEditingController(text: tx.note ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Transaction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedTx = TransactionModel(
                userId: tx.userId,
                amount: double.tryParse(amountController.text) ?? tx.amount,
                type: tx.type,
                category: tx.category,
                date: tx.date,
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
              );
              context.read<TransactionBloc>().add(
                UpdateTransaction(old: tx, updated: updatedTx),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
