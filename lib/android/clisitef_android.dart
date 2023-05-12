library clisitef;

import 'package:clisitef/clisitef_sdk.dart';
import 'package:clisitef/model/clisitef_data.dart';
import 'package:clisitef/model/data_events.dart';
import 'package:clisitef/model/modalidade.dart';
import 'package:clisitef/model/pinpad_events.dart';
import 'package:clisitef/model/pinpad_information.dart';
import 'package:clisitef/model/transaction_events.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CliSiTefAndroid implements CliSiTefSDK {
  CliSiTefAndroid._privateConstructor();

  static final CliSiTefAndroid _instance =
      CliSiTefAndroid._privateConstructor();

  static const MethodChannel _methodChannel =
      MethodChannel('com.loopmarket.clisitef');

  static const EventChannel _eventChannel =
      EventChannel('com.loopmarket.clisitef/events');

  static const EventChannel _dataChannel =
      EventChannel('com.loopmarket.clisitef/events/data');

  factory CliSiTefAndroid() {
    return _instance;
  }

  @override
  void setEventHandler(TransactionEvent2Void? transactionEventHandler,
      PinPadEvent2Void? pinPadEventHandler) {
    _eventChannel.receiveBroadcastStream().listen(
        (event) =>
            handleEvent(event, transactionEventHandler, pinPadEventHandler),
        onError: (event) =>
            handleError(event, transactionEventHandler, pinPadEventHandler));
  }

  @override
  void setDataHandler(Data2Void listener) {
    _dataChannel.receiveBroadcastStream().listen((dataEvent) => listener(
        CliSiTefData(
            event: dataEvent['event'].toString().dataEvent,
            currentStage: dataEvent['currentStage'],
            buffer: dataEvent['buffer'],
            waiting: !dataEvent['shouldContinue'],
            fieldId: dataEvent['fieldId'],
            maxLength: dataEvent['maxLength'],
            minLength: dataEvent['minLength'])));
  }

  @override
  Future<bool> abortTransaction() async {
    bool? success = await _methodChannel
        .invokeMethod<bool>('abortTransaction', {'continua': 0});

    return success ?? false;
  }

  @override

  /// If an error occurs it throw an
  /// [PlatformException] with status code related to the error
  Future<bool> configure(String enderecoSitef, String codigoLoja,
      String numeroTerminal, String cnpjEmpresa, String cnpjLoja) async {
    bool? success = await _methodChannel.invokeMethod<bool>('configure', {
      'enderecoSitef': enderecoSitef,
      'codigoLoja': codigoLoja.padLeft(8, '0'),
      'numeroTerminal': numeroTerminal.padLeft(8, '0'),
      'cnpjEmpresa': cnpjEmpresa,
      'cnpjLoja': cnpjLoja
    });

    return success ?? false;
  }

  @override
  Future<bool> finishTransaction(
      bool confirma, String cupomFiscal, DateTime dataFiscal) async {
    bool? success =
        await _methodChannel.invokeMethod<bool>('finishTransaction', {
      'confirma': confirma == true ? 1 : 0,
      'cupomFiscal': cupomFiscal,
      'dataFiscal': DateFormat('yyyyMMdd').format(dataFiscal),
      'horaFiscal': DateFormat('hhmmss').format(dataFiscal)
    });

    return success ?? false;
  }

  @override
  Future<bool> finishLastTransaction(bool confirma) async {
    bool? success =
        await _methodChannel.invokeMethod<bool>('finishLastTransaction', {
      'confirma': confirma == true ? 1 : 0,
    });

    return success ?? false;
  }

  @override
  Future<bool> continueTransaction(String data) async {
    bool? success =
        await _methodChannel.invokeMethod<bool>('continueTransaction', {
      'data': data,
    });

    return success ?? false;
  }

  @override
  Future<int> getPinPadYesOrNo(String message) async {
    int? result = await _methodChannel
        .invokeMethod<int>('pinpadReadYesNo', {'message': message});
    if (result == null) {
      throw Exception('Could not retrieve pinpad information');
    }
    return result;
  }

  @override
  Future<PinPadInformation> getPinpadInformation() async {
    bool? isPresent =
        await _methodChannel.invokeMethod<bool>('pinpadIsPresent');

    return PinPadInformation(isPresent: isPresent ?? false);
  }

  @override
  Future<int?> getTotalPendingTransactions(
      DateTime dataFiscal, String cupomFiscal) async {
    return await _methodChannel
        .invokeMethod<int?>('getQttPendingTransactions', {
      'dataFiscal': DateFormat('yyyyMMdd').format(dataFiscal),
      'cupomFiscal': cupomFiscal
    });
  }

  @override
  Future<int?> setPinpadDisplayMessage(String message) async {
    return await _methodChannel
        .invokeMethod<int>('setPinpadDisplayMessage', {'message': message});
  }

  @override
  Future<bool> startTransaction(Modalidade modalidade, double valor,
      String cupomFiscal, DateTime dataFiscal, String operador) async {
    NumberFormat f = NumberFormat("############.00", "pt");
    bool? success =
        await _methodChannel.invokeMethod<bool>('startTransaction', {
      'modalidade': modalidade.value,
      'valor': f.format(valor),
      'cupomFiscal': cupomFiscal,
      'dataFiscal': DateFormat('yyyyMMdd').format(dataFiscal),
      'horario': DateFormat('hhmmss').format(dataFiscal),
      'operador': operador,
    });

    return success ?? false;
  }

  handleEvent(String event, TransactionEvent2Void? transactionEventHandler,
      PinPadEvent2Void? pinPadEventHandler) {
    if (transactionEventHandler != null) {
      if (event.transactionEvent != TransactionEvents.unknown) {
        transactionEventHandler(event.transactionEvent);
      }
    }

    if (pinPadEventHandler != null) {
      if (event.pinPadEvent != PinPadEvents.unknown) {
        pinPadEventHandler(event.pinPadEvent);
      }
    }
  }

  handleError(
      PlatformException exception,
      TransactionEvent2Void? transactionEventHandler,
      PinPadEvent2Void? pinPadEventHandler) {
    if (transactionEventHandler != null) {
      if (exception.code.transactionEvent != TransactionEvents.unknown) {
        transactionEventHandler(exception.code.transactionEvent,
            exception: exception);
      }
    }

    if (pinPadEventHandler != null) {
      if (exception.code.pinPadEvent != PinPadEvents.unknown) {
        pinPadEventHandler(exception.code.pinPadEvent, exception: exception);
      }
    }
  }
}
