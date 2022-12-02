library clisitef;

import 'package:clisitef/model/clisitef_data.dart';
import 'package:clisitef/model/modalidade.dart';
import 'package:clisitef/model/pinpad_events.dart';
import 'package:clisitef/model/pinpad_information.dart';
import 'package:clisitef/model/transaction_events.dart';
import 'package:flutter/services.dart';

typedef TransactionEvent2Void = void Function(TransactionEvents, { PlatformException? exception });

typedef PinPadEvent2Void = void Function(PinPadEvents, { PlatformException? exception });

typedef Data2Void = void Function(CliSiTefData);

abstract class CliSiTefSDK {
  Future<bool> abortTransaction();

  Future<bool> continueTransaction(String data);

  Future<bool> configure(String enderecoSitef, String codigoLoja, String numeroTerminal);

  Future<bool> finishTransaction(bool confirma, String cupomFiscal, DateTime dataFiscal);

  Future<bool> finishLastTransaction(bool confirma);

  Future<bool> startTransaction(Modalidade modalidade, double valor, String cupomFiscal, DateTime dataFiscal, String operador);

  Future<int?> getTotalPendingTransactions(DateTime dataFiscal, String cupomFiscal);

  Future<PinPadInformation> getPinpadInformation();

  Future<int> getPinPadYesOrNo(String message);

  Future<int?> setPinpadDisplayMessage(String message);

  void setEventHandler(TransactionEvent2Void? transactionEventHandler, PinPadEvent2Void? pinPadEventHandler);

  void setDataHandler(Data2Void listener);
}