/// A Sidekick plugin that connects the flutterw script to the sidekick flutter command
library flutterw_sidekick_plugin;

import 'package:flutterw_sidekick_plugin/src/flutterw.dart';
import 'package:sidekick_core/sidekick_core.dart';

export 'package:flutterw_sidekick_plugin/src/flutterw.dart';

Future<void> initializeFlutterWrapper(SdkInitializerContext context) async {
  final flutterSdkDir = context.flutterSdk;

  if (flutterSdkDir?.file('bin/flutter').existsSync() == true) {
    // already initialized
    return;
  }
  // initialize and download the flutter submodule by executing the `flutterw` bash script
  flutterw(['--version']);
}
