library flutterw_sidekick_plugin;

import 'package:flutterw_sidekick_plugin/src/flutterw.dart';
import 'package:sidekick_core/sidekick_core.dart';

export 'package:flutterw_sidekick_plugin/src/flutterw.dart';

void initializeFlutterWrapper(Directory sdk) {
  if (sdk.file('bin/flutter').existsSync()) {
    // already initialized
    return;
  }
  // initialize and download the flutter submodule by executing the `flutterw` bash script
  flutterw(['--version']);
}
