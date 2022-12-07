import 'package:pub_semver/pub_semver.dart';
import 'package:sidekick_core/sidekick_core.dart';
import 'package:yaml/yaml.dart';

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
  final rawConstraint = (((yaml.contents as YamlMap?)?['packages']
      as YamlMap?)?[dependency] as YamlMap?)?['version'] as String?;
  if (rawConstraint == null) {
    // no version for package found
    return;
  }
  final depConstraint = VersionConstraint.parse(rawConstraint);
  if (!depConstraint.allowsAny(version)) {
    throw 'Require package:$dependency to support version $version but it is locked at version $depConstraint. Please upgrade package:$dependency';
  }
}
