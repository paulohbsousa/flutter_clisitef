library clisitef;

import 'package:clisitef/model/transaction_events.dart';

class Transaction {
  bool done = false;

  bool success = false;

  int id = 0;

  TransactionEvents? event;
}