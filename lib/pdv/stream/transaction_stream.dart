library clisitef;

import 'dart:async';

import 'package:clisitef/model/transaction.dart';
import 'package:clisitef/model/transaction_events.dart';

class TransactionStream {
  TransactionStream(
      {void Function()? onListen,
      void Function()? onPause,
      void Function()? onResume,
      FutureOr<void> Function()? onCancel}) {
    _controller = StreamController<Transaction>(
        onCancel: onCancel,
        onListen: onListen,
        onPause: onPause,
        onResume: onResume);
  }

  StreamController<Transaction> _controller = StreamController<Transaction>();

  final Transaction _internalTransaction = Transaction();

  Transaction get transaction => _internalTransaction;

  Stream<Transaction> get stream => _controller.stream;

  void done() {
    _internalTransaction.done = true;
    emit(_internalTransaction);
    close();
  }

  void success(bool success) {
    _internalTransaction.success = success;
  }

  void event(TransactionEvents event) {
    _internalTransaction.event = event;
  }

  void emit(Transaction transaction) {
    _controller.sink.add(transaction);
  }

  void close() {
    _controller.sink.close();
  }
}
