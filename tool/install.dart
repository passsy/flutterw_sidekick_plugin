import 'package:flutterw_sidekick_plugin/src/initialize_sidekick.dart';
import 'package:sidekick_core/sidekick_core.dart'
    hide cliName, repository, mainProject;
import 'package:sidekick_core/sidekick_core.dart';
import 'package:sidekick_plugin_installer/sidekick_plugin_installer.dart';

Future<void> main() async {
  final SidekickPackage package = PluginContext.sidekickPackage;

  installFlutterWrapper(findRepository().root);

  if (PluginContext.localPlugin == null) {
    pubAddDependency(package, 'flutterw_sidekick_plugin');
  } else {
    // For local development
    pubAddLocalDependency(package, PluginContext.localPlugin!.root.path);
  }
  pubGet(package);

  final mainFile = package.cliMainFile;
  if (!mainFile.existsSync()) {
    throw "Could not find file ${mainFile.path} to register the dart commands";
  }

  findInitializeSidekick(mainFile)
      .addFlutterSdkPath("findRepository().root.directory('.flutterw').path");

  // Usually the Flutter and Dart command from sidekick_core are already present
  // Add them in case they are not
  final mainContent = mainFile.readAsStringSync();
  if (!mainContent.contains('FlutterCommand()')) {
    registerPlugin(
      sidekickCli: package,
      command: 'FlutterCommand()',
    );
  }
  if (!mainContent.contains('DartCommand()')) {
    registerPlugin(
      sidekickCli: package,
      command: 'DartCommand()',
    );
  }
}

/// Installs the [flutter_wrapper](https://github.com/passsy/flutter_wrapper) in
/// [directory] using the provided install script
Future<File> installFlutterWrapper(Directory directory) async {
  writeAndRunShellScript(
    r'sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"',
    workingDirectory: directory,
  );
  final exe = directory.file('flutterw');
  assert(exe.existsSync());
  return exe;
}
