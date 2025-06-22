import 'package:expensify/models/transaction_model.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  TransactionLoaded(this.transactions);
}

class TransactionAdded extends TransactionState {} // ✅ Add this

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}
