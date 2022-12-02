import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:clisitef/clisitef_method_channel.dart';

void main() {
  // MethodChannelClisitef platform = MethodChannelClisitef();
  const MethodChannel channel = MethodChannel('clisitef');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
