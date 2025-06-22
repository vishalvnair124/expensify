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
      final key = _findKeyForTransaction(event.old);
      if (key != null) {
        await box.put(key, event.updated.toJson());
        add(LoadTransactions());
      } else {
        emit(TransactionError("Transaction not found"));
      }
    });

    on<DeleteTransaction>((event, emit) async {
      final key = _findKeyForTransaction(event.transaction);
      if (key != null) {
        await box.delete(key);
        add(LoadTransactions());
      } else {
        emit(TransactionError("Transaction not found"));
      }
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
