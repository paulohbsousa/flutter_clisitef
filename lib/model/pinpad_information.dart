library clisitef;

import 'package:clisitef/model/pinpad_events.dart';

class PinPadInformation {
  PinPadInformation({required this.isPresent});

  bool isPresent;

  bool isBluetoothEnabled = false;

  bool isConnected = false;

  bool isReady = false;

  bool waiting = false;

  bool isSimulated = false;

  PinPadEvents event = PinPadEvents.unknown;
}
