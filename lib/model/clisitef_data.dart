library clisitef;

import 'package:clisitef/model/data_events.dart';

class CliSiTefData {
  CliSiTefData(
      {required this.event,
        required this.currentStage,
        required this.buffer,
        required this.waiting,
        this.fieldId = 0,
        this.maxLength = 0,
        this.minLength = 0});

  DataEvents event;

  int currentStage;

  String buffer;

  bool waiting = false;

  int fieldId;

  int maxLength;

  int minLength;

  isClientInvoice() {
    return event == DataEvents.data && fieldId == 121;
  }

  isCompanyInvoice() {
    return event == DataEvents.data && fieldId == 122;
  }
}
