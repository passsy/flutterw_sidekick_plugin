import 'package:sidekick_core/sidekick_core.dart';
import 'package:yaml/yaml.dart';
import 'package:pub_semver/pub_semver.dart';
export 'package:pub_semver/pub_semver.dart';

void requireDependencyVersion(
  SidekickPackage package,
  String dependency,
  VersionConstraint version,
) {
  final lockFile = package.root.file('pubspec.lock');
  if (!lockFile.existsSync()) {
    return;
  }
  final yaml = loadYamlDocument(lockFile.readAsStringSync());
  final rawConstraint =
      (yaml.contents as YamlMap)['packages'][dependency]['version'] as String;
  final depConstraint = VersionConstraint.parse(rawConstraint);

  if (!depConstraint.allowsAll(depConstraint)) {
    throw 'Require package:$dependency to support version $version but it is locked at version $depConstraint. Please upgrade package:$dependency';
  }
}
