import 'package:expensify/models/transaction_model.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;
  AddTransaction(this.transaction);
}

class UpdateTransaction extends TransactionEvent {
  final TransactionModel old;
  final TransactionModel updated;
  UpdateTransaction({required this.old, required this.updated});
}

class DeleteTransaction extends TransactionEvent {
  final TransactionModel transaction;
  DeleteTransaction(this.transaction);
}
