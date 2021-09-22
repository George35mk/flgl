import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flgl/flgl.dart';

void main() {
  const MethodChannel channel = MethodChannel('flgl');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // var flgl = Flgl(100, 100, 1);
    // expect(await flgl.platformVersion, '42');
  });
}
