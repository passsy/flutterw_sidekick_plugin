import 'package:flutterw_sidekick_plugin/flutterw_sidekick_plugin.dart';
import 'package:sidekick_core/sidekick_core.dart';
import 'package:test/test.dart';

void main() {
  test('initializer is SdkInitializer', () {
    const SdkInitializer initializer = initializeFlutterWrapper;
    expect(initializer, isA<SdkInitializer>());
  });
}
