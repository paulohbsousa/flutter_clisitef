library clisitef;

import 'dart:io';

import 'package:clisitef/android/clisitef_android.dart';
import 'package:clisitef/clisitef_sdk.dart';
import 'package:flutter/services.dart';

class Clisitef {
  Clisitef._();

  static CliSiTefSDK get instance => Platform.isAndroid
      ? CliSiTefAndroid()
      : throw PlatformException(
      code: 'NotSupported',
      message: 'This library only supports Android applications');
}
