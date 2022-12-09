import 'package:sidekick_core/sidekick_core.dart'
    hide cliName, repository, mainProject;
import 'package:sidekick_core/sidekick_core.dart';
import 'package:sidekick_plugin_installer/sidekick_plugin_installer.dart';

import 'src/main_file_modifiers.dart';
import 'src/modifiable_source_file.dart';
import 'src/require_dependency_version.dart';

Future<void> main() async {
  final SidekickPackage package = PluginContext.sidekickPackage;

  requireDependencyVersion(
    package,
    'sidekick_core',
    VersionConstraint.parse('>=0.11.0'),
  );

  final repoRoot = findRepository().root;
  installFlutterWrapper(repoRoot);

  print('Installing self ${env.entries}');
  addSelfAsDependency();
  pubGet(package);

  final mainFile = package.cliMainFile;
  if (!mainFile.existsSync()) {
    throw "Could not find file ${mainFile.path} to register the dart commands";
  }

  final ModifiableSourceFile mainSourceFile = ModifiableSourceFile(mainFile);
  mainSourceFile.addFlutterSdkPath("'.flutter'"); // relative to repo root
  mainSourceFile.addImport(
    "import 'package:flutterw_sidekick_plugin/flutterw_sidekick_plugin.dart';",
  );
  mainSourceFile.registerSdkInitializer(
    'addFlutterSdkInitializer(initializeFlutterWrapper);',
  );
  mainSourceFile.flush();

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

  print(green('Successfully installed flutterw'));
  print('\nUsage: You can now execute the commands:\n'
      '- ${package.cliName} flutter\n'
      '- ${package.cliName} dart\n'
      'to run flutter or dart commands with the pinned Flutter SDK.');
}

/// Installs the [flutter_wrapper](https://github.com/passsy/flutter_wrapper) in
/// [directory] using the provided install script
Future<File> installFlutterWrapper(Directory directory) async {
  writeAndRunShellScript(
    r'sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"',
    workingDirectory: directory,
    progress: Progress.devNull(),
  );
  final exe = directory.file('flutterw');
  assert(exe.existsSync());
  return exe;
}
