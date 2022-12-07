library clisitef;

import 'package:clisitef/clisitef_sdk.dart';
import 'package:clisitef/model/clisitef_configuration.dart';
import 'package:clisitef/model/clisitef_data.dart';
import 'package:clisitef/model/modalidade.dart';
import 'package:clisitef/model/pinpad_events.dart';
import 'package:clisitef/model/pinpad_information.dart';
import 'package:clisitef/model/transaction.dart';
import 'package:clisitef/model/transaction_events.dart';
import 'package:clisitef/pdv/stream/data_stream.dart';
import 'package:clisitef/pdv/stream/pin_pad_stream.dart';
import 'package:clisitef/pdv/stream/transaction_stream.dart';
import 'package:flutter/services.dart';

class CliSiTefPDV {
  CliSiTefPDV({ required this.client, required this.configuration, this.isSimulated = false }) {
    client.configure(configuration.enderecoSitef, configuration.codigoLoja, configuration.numeroTerminal);
    client.setEventHandler(null, onPinPadEvent);
    client.setDataHandler(onData);
  }

  CliSiTefConfiguration configuration;

  CliSiTefSDK client;

  TransactionStream? _transactionStream;

  bool isSimulated;

  final PinPadStream _pinPadStream = PinPadStream();

  PinPadStream get pinPadStream => _pinPadStream;

  final DataStream _dataStream = DataStream();

  DataStream get dataStream => _dataStream;

  Future<Stream<Transaction>> payment(Modalidade modalidade, double valor, { required String cupomFiscal, required DateTime dataFiscal, String operador = '' }) async {
    if (_transactionStream != null) {
      throw Exception('Another transaction is already in progress.');
    }
    try {
      bool success = await client.startTransaction(modalidade, valor, cupomFiscal, dataFiscal, operador);
      if (!success) {
        throw Exception('Unable to start payment process');
      }
    } on Exception {
      rethrow;
    }

    _transactionStream = TransactionStream(
      onCancel: () => client.abortTransaction(),
    );
    client.setEventHandler(onTransactionEvent, onPinPadEvent);
    return _transactionStream!.stream;
  }

  Future<bool> continueTransaction(String data) async {
    return client.continueTransaction(data);
  }

  Future<bool> isPinPadPresent() async {
    if (isSimulated) {
      PinPadInformation pinPadSimulatedInfo = PinPadInformation(isPresent: true);
      pinPadSimulatedInfo.isConnected = true;
      pinPadSimulatedInfo.isReady = true;
      pinPadStream.emit(pinPadSimulatedInfo);
      return true;
    }
    PinPadInformation pinPad = await client.getPinpadInformation();
    PinPadInformation pinPadStreamInfo = _pinPadStream.pinPadInfo;
    pinPadStreamInfo.isPresent = pinPad.isPresent;
    pinPadStream.emit(pinPadStreamInfo);
    return _pinPadStream.pinPadInfo.isPresent;
  }

  Future<void> cancelTransaction() async {
    try {
      await client.finishLastTransaction(false);
    } on PlatformException catch (e) {
      if (e.code == '-12') {
        await client.abortTransaction();
      } else {
        rethrow;
      }
    }

    if (_transactionStream != null) {
      _transactionStream!.success(false);
      _transactionStream!.emit(_transactionStream!.transaction);
    }
  }

  onTransactionEvent(TransactionEvents event, { PlatformException? exception }) {
    Transaction? t = _transactionStream?.transaction;
    if (t != null) {
      switch(event) {
        case TransactionEvents.transactionConfirm:
          _transactionStream?.success(true);
          break;
        case TransactionEvents.transactionOk:
          _transactionStream?.success(true);
          break;
        case TransactionEvents.transactionError:
        case TransactionEvents.transactionFailed:
          _transactionStream?.success(false);
          break;
        default:
        //noop
      }
      _transactionStream?.event(event);
      _transactionStream?.done();
      _transactionStream = null;
    }
  }

  onPinPadEvent(PinPadEvents event, { PlatformException? exception }) {
    PinPadInformation pinPad = _pinPadStream.pinPadInfo;
    pinPad.event = event;
    switch(event) {
      case PinPadEvents.startBluetooth:
        pinPad.waiting = true;
        pinPad.isBluetoothEnabled = false;
        break;
      case PinPadEvents.endBluetooth:
        pinPad.waiting = false;
        pinPad.isBluetoothEnabled = true;
        break;
      case PinPadEvents.waitingPinPadConnection:
        pinPad.waiting = true;
        pinPad.isConnected = false;
        break;
      case PinPadEvents.pinPadOk:
        pinPad.waiting = false;
        pinPad.isConnected = true;
        break;
      case PinPadEvents.waitingPinPadBluetooth:
        pinPad.waiting = true;
        pinPad.isReady = false;
        break;
      case PinPadEvents.pinPadBluetoothConnected:
        pinPad.waiting = false;
        pinPad.isReady = true;
        break;
      case PinPadEvents.pinPadBluetoothDisconnected:
        pinPad.waiting = false;
        pinPad.isReady = false;
        break;
      case PinPadEvents.unknown:
      case PinPadEvents.genericError:
        _pinPadStream.error(exception ?? 'Unhandled event $event');
        return;
    }
    _pinPadStream.emit(pinPad);
  }

  void onData(CliSiTefData data) {
    _dataStream.sink.add(data);
  }
}