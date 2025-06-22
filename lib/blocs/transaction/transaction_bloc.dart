import 'package:expensify/models/transaction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Box box = Hive.box('transactions');

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>((event, emit) {
      emit(TransactionLoading());
      final all = box.values
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emit(TransactionLoaded(all));
    });

    on<AddTransaction>((event, emit) async {
      await box.add(event.transaction.toJson());
      add(LoadTransactions());
    });

    on<UpdateTransaction>((event, emit) async {
      final box = Hive.box('transactions');
      final usersBox = Hive.box('users');

      // Adjust balance: remove old, add new
      final user = Map<String, dynamic>.from(usersBox.get(event.old.userId)!);
      double balance = user['currentBalance'];

      balance += event.old.type == 'Income'
          ? -event.old.amount
          : event.old.amount;
      balance += event.updated.type == 'Income'
          ? event.updated.amount
          : -event.updated.amount;

      user['currentBalance'] = balance;
      usersBox.put(event.old.userId, user);

      final key = box.keys.firstWhere(
        (k) => box.get(k) == event.old.toJson(),
        orElse: () => null,
      );
      if (key != null) {
        await box.put(key, event.updated.toJson());
      }
      add(LoadTransactions());
    });

    on<DeleteTransaction>((event, emit) async {
      final box = Hive.box('transactions');
      final usersBox = Hive.box('users');

      final user = Map<String, dynamic>.from(
        usersBox.get(event.transaction.userId)!,
      );
      double balance = user['currentBalance'];

      balance += event.transaction.type == 'Income'
          ? -event.transaction.amount
          : event.transaction.amount;

      user['currentBalance'] = balance;
      usersBox.put(event.transaction.userId, user);

      final key = box.keys.firstWhere(
        (k) => box.get(k) == event.transaction.toJson(),
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
      }
      add(LoadTransactions());
    });
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
            value.date == tx.date &&
            value.note == tx.note;
      }).key;
    } catch (_) {
      return null;
    }
  }
}
