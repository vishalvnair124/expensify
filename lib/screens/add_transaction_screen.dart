import 'package:expensify/blocs/transaction/transaction_bloc.dart';
import 'package:expensify/blocs/transaction/transaction_event.dart';
import 'package:expensify/blocs/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final int userId;

  const AddTransactionScreen({super.key, required this.userId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = "Income";
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  List<String> _userCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final box = Hive.box('categories');
    final items = box.values
        .cast<Map>()
        .where(
          (item) => item['userId'] == widget.userId && item['type'] == _type,
        )
        .toList();
    setState(() {
      _userCategories = items.map((e) => e['name'] as String).toList();
      _selectedCategory = _userCategories.isNotEmpty
          ? _userCategories[0]
          : null;
    });
  }

  void _saveTransaction() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedCategory == null) return;

    final transaction = TransactionModel(
      userId: widget.userId,
      amount: double.tryParse(amountText) ?? 0,
      type: _type,
      category: _selectedCategory!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    context.read<TransactionBloc>().add(AddTransaction(transaction));
    context.read<TransactionBloc>().add(LoadTransactions());
    Navigator.pop(context);
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _selectedDate.hour,
          pickedTime?.minute ?? _selectedDate.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Transaction added successfully")),
            );
            _amountController.clear();
            _noteController.clear();
            setState(() {
              _selectedCategory = _userCategories.isNotEmpty
                  ? _userCategories[0]
                  : null;
              _selectedDate = DateTime.now();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Type: "),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _type,
                    items: const [
                      DropdownMenuItem(value: "Income", child: Text("Income")),
                      DropdownMenuItem(
                        value: "Expense",
                        child: Text("Expense"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        _loadCategories();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                hint: const Text("Select Category"),
                items: _userCategories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  "Date: ${_selectedDate.toString().substring(0, 16)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Notes (optional)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.save),
                label: const Text("Save Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
