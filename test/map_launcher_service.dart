import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tap_eat/service/map_launcher_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final service = MapLauncherService();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'launchNavigation restituisce true se canLaunch e launch funzionano',
    () async {
      bool launchCalled = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'canLaunch') return true;
            if (call.method == 'launch') {
              launchCalled = true;
              return true;
            }
            return null;
          });

      final result = await service.launchNavigation(40.0, 14.0);
      expect(result, isTrue);
      expect(launchCalled, isTrue);
    },
  );

  test('launchNavigation restituisce false se canLaunch è false', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'canLaunch') return false;
          return null;
        });

    final result = await service.launchNavigation(41.0, 12.0);
    expect(result, isFalse);
  });
}
