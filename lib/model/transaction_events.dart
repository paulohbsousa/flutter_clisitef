enum TransactionEvents {
  unknown,
  transactionConfirm,
  transactionFailed,
  transactionOk,
  transactionError
}

extension TransactionEventsString on String  {
  TransactionEvents get transactionEvent {
    switch (this) {
      case 'TRANSACTION_CONFIRM':
        return TransactionEvents.transactionConfirm;
      case 'TRANSACTION_FAILED':
        return TransactionEvents.transactionFailed;
      case 'TRANSACTION_OK':
        return TransactionEvents.transactionOk;
      case 'TRANSACTION_ERROR':
        return TransactionEvents.transactionError;
    }
    return TransactionEvents.unknown;
  }
}