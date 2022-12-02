library clisitef;

import 'dart:async';

import 'package:clisitef/model/pinpad_information.dart';

class PinPadStream {
  final _controller = StreamController<PinPadInformation>();

  PinPadInformation _internalPinPadInfo = PinPadInformation(isPresent: false);

  PinPadInformation get pinPadInfo => _internalPinPadInfo;

  Stream<PinPadInformation> get stream => _controller.stream;

  void emit(PinPadInformation pinPadInformation) {
    _internalPinPadInfo = pinPadInformation;
    _controller.sink.add(_internalPinPadInfo);
  }
  
  void close() {
    _controller.sink.close();
  }

  void error(Object error) {
    _controller.sink.addError(error);
  }
}

