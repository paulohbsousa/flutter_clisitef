import 'dart:convert';

import 'package:clisitef/model/clisitef_configuration.dart';
import 'package:clisitef/model/clisitef_data.dart';
import 'package:clisitef/model/data_events.dart';
import 'package:clisitef/model/modalidade.dart';
import 'package:clisitef/model/pinpad_information.dart';
import 'package:clisitef/model/transaction.dart';
import 'package:clisitef/model/transaction_events.dart';
import 'package:clisitef/pdv/clisitef_pdv.dart';
import 'package:clisitef/pdv/simulated_pin_pad_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:clisitef/clisitef.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _clisitefPlugin = Clisitef.instance;

  late CliSiTefPDV pdv;

  String pinPadInfo = '';

  bool _isSimulated = true;

  TransactionEvents transactionStatus = TransactionEvents.unknown;

  List<String> dataReceived = [];

  String _lastTitle = '';

  @override
  void initState() {
    super.initState();
    CliSiTefConfiguration configuration = CliSiTefConfiguration(
        enderecoSitef: '10.211.55.3', codigoLoja: '0', numeroTerminal: '1');
    pdv = CliSiTefPDV(
        client: _clisitefPlugin,
        configuration: configuration,
        isSimulated: _isSimulated);

    pdv.pinPadStream.stream.listen((PinPadInformation event) {
      setState(() {
        PinPadInformation pinPad = event;
        pinPadInfo =
            'isPresent: ${pinPad.isPresent.toString()} \n isBluetoothEnabled: ${pinPad.isBluetoothEnabled.toString()} \n isConnected: ${pinPad.isConnected.toString()} \n isReady: ${pinPad.isReady.toString()} \n event: ${pinPad.event.toString()} ';
      });
    });

    pdv.dataStream.stream.listen((CliSiTefData event) {

      print(event.buffer);
      print(event.event);

      if (event.event == DataEvents.menuTitle) {
        _lastTitle = event.buffer;
      }

      if (event.event == DataEvents.menuOptions || event.event == DataEvents.getField) {
        showDialog(
            context: context,
            builder: (context) {
              return SimulatedPinPadWidget(title: _lastTitle, options: event.buffer, submit: (id) {
                pdv.continueTransaction(id);
              },);
            });
      }
      setState(() {
        if (event.event == DataEvents.data) {
          if (event.isClientInvoice()) {
            dataReceived.add("Client Invoice:${event.buffer}");
          }
          if (event.isCompanyInvoice()) {
            dataReceived.add("Company Invoice:${event.buffer}");
          }
        } else {
          if (event.buffer != "") {
            dataReceived.add(event.buffer);
          }
        }
      });
    });
  }

  void pinpad() async {
    try {
      await pdv.isPinPadPresent();

      setState(() {
        PinPadInformation pinPad = pdv.pinPadStream.pinPadInfo;
        pinPadInfo =
            'isPresent: ${pinPad.isPresent.toString()} \n isBluetoothEnabled: ${pinPad.isBluetoothEnabled.toString()} \n isConnected: ${pinPad.isConnected.toString()} \n isReady: ${pinPad.isReady.toString()} \n event: ${pinPad.event.toString()} ';
      });
    } on Exception {
      print('Failed!');
    }
  }

  void transaction() async {
    try {
      Stream<Transaction> paymentStream = await pdv.payment(
          Modalidade.test, 100,
          cupomFiscal: '1', dataFiscal: DateTime.now());

      if (_isSimulated) {
        print('here is simulated');
      }

      paymentStream.listen((Transaction transaction) {
        setState(() {
          transactionStatus = transaction.event ?? TransactionEvents.unknown;
        });
      });
    } on Exception catch (e) {
      setState(() {
        transactionStatus = TransactionEvents.transactionError;
      });
      print(e.toString());
    }
  }

  void cancel() async {
    try {
      await pdv.cancelTransaction();
      setState(() {
        dataReceived = [];
      });
    } on Exception catch (e) {
      print('Cancel!');
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () => pinpad(),
                  child: Text('Verificar presenca pinpad')),
              ElevatedButton(
                  onPressed: () => transaction(),
                  child: Text('Iniciar transacao')),
              ElevatedButton(
                  onPressed: () => cancel(),
                  child: Text('Cancela ultima transacao')),
              Text("PinPadInfo:"),
              Text(pinPadInfo),
              Text("\n\nTransaction Status:"),
              Text(transactionStatus.toString()),
              Text("\n\nData Received:"),
              Text(dataReceived.join('\n')),
            ],
          ),
        ),
      ),
    );
  }
}
