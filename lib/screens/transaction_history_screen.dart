import 'package:expensify/blocs/transaction/transaction_bloc.dart';
import 'package:expensify/blocs/transaction/transaction_event.dart';
import 'package:expensify/blocs/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction_model.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final int userId;

  const TransactionHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions
                .where((tx) => tx.userId == userId)
                .toList();

            if (transactions.isEmpty) {
              return const Center(child: Text("No Transactions Found"));
            }

            final grouped = _groupByDate(transactions);

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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...items.map((tx) {
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
                              "${tx.type == 'Income' ? '+' : '-'} ₹${tx.amount}",
                              style: TextStyle(
                                color: tx.type == 'Income'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(context, tx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<TransactionBloc>().add(
                                  DeleteTransaction(tx),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text("Failed to load transactions."));
          }
        },
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txs) {
    Map<String, List<TransactionModel>> grouped = {};
    for (var tx in txs) {
      final key = "${tx.date.year}-${tx.date.month}-${tx.date.day}";
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
                amount: double.tryParse(amountController.text) ?? 0,
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
