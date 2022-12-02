library clisitef;

import 'dart:async';

import 'package:clisitef/model/clisitef_data.dart';
import 'package:clisitef/model/pinpad_information.dart';

class DataStream {
  final _controller = StreamController<CliSiTefData>();

  Stream<CliSiTefData> get stream => _controller.stream;

  StreamSink<CliSiTefData> get sink => _controller.sink;
}

