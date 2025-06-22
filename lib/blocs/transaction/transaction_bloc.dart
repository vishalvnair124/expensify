import 'dart:convert';
import 'package:expensify/models/transaction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Box box = Hive.box('transactions');

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) {
    emit(TransactionLoading());
    try {
      final all = box.values
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emit(TransactionLoaded(all));
    } catch (e) {
      emit(TransactionError("Failed to load transactions: ${e.toString()}"));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    await box.add(event.transaction.toJson());
    await _updateUserBalance(
      event.transaction.userId,
      event.transaction,
      isAdd: true,
    );
    add(LoadTransactions());
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final key = _findKeyForTransaction(event.old);
    if (key != null) {
      // Remove old effect
      await _updateUserBalance(event.old.userId, event.old, isDelete: true);
      // Add new effect
      await _updateUserBalance(
        event.updated.userId,
        event.updated,
        isAdd: true,
      );
      await box.put(key, event.updated.toJson());
      add(LoadTransactions());
    } else {
      emit(TransactionError("Transaction not found"));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final key = _findKeyForTransaction(event.transaction);
    if (key != null) {
      await _updateUserBalance(
        event.transaction.userId,
        event.transaction,
        isDelete: true,
      );
      await box.delete(key);
      add(LoadTransactions());
    } else {
      emit(TransactionError("Transaction not found"));
    }
  }

  dynamic _findKeyForTransaction(TransactionModel tx) {
    try {
      return box.toMap().entries.firstWhere((entry) {
        final value = TransactionModel.fromJson(
          Map<String, dynamic>.from(entry.value),
        );
        return value.userId == tx.userId &&
            value.amount == tx.amount &&
            value.type == tx.type &&
            value.category == tx.category &&
            value.date.toIso8601String() == tx.date.toIso8601String() &&
            value.note == tx.note;
      }).key;
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateUserBalance(
    int userId,
    TransactionModel tx, {
    bool isAdd = false,
    bool isDelete = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];

    for (int i = 0; i < users.length; i++) {
      final user = jsonDecode(users[i]);
      if (user['userId'] == userId) {
        double balance = (user['currentBalance'] ?? 0).toDouble();
        final amount = tx.amount;

        if (tx.type == 'Income') {
          balance += isAdd ? amount : -amount;
        } else {
          balance += isAdd ? -amount : amount;
        }

        if (balance < 0) balance = 0;
        user['currentBalance'] = balance;
        users[i] = jsonEncode(user);
        break;
      }
    }

    await prefs.setStringList('users', users);

    // Also update the 'user' key (current session)
    final currentUserString = prefs.getString('user');
    if (currentUserString != null) {
      final currentUser = jsonDecode(currentUserString);
      if (currentUser['userId'] == userId) {
        final updatedUser = jsonDecode(
          users.firstWhere((u) => jsonDecode(u)['userId'] == userId),
        );
        currentUser['currentBalance'] = updatedUser['currentBalance'];
        await prefs.setString('user', jsonEncode(currentUser));
      }
    }
  }
}
