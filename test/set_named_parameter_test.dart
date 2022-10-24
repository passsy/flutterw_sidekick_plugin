import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutterw_sidekick_plugin/src/initialize_sidekick.dart';
import 'package:flutterw_sidekick_plugin/src/modifiable_source_file.dart';
import 'package:indent/indent.dart';
import 'package:sidekick_core/sidekick_core.dart';
import 'package:test/test.dart';

void main() {
  test('add first parameter', () {
    final source = _tempSourceFile(
      StringIndentation("""
        |void main() {
        |  foo();
        |}
        """).trimMargin(),
    );
    final fooMethod = source.findMethodInvocationByName('foo');
    setNamedParameter(source, fooMethod, name: 'bar', value: "'c'");
    expect(source.content, contains("  foo(bar: 'c');"));
  });

  test('update first parameter', () {
    final source = _tempSourceFile(
      StringIndentation("""
        |void main() {
        |  foo(bar: 'a');
        |}
        """).trimMargin(),
    );
    final fooMethod = source.findMethodInvocationByName('foo');
    setNamedParameter(source, fooMethod, name: 'bar', value: "'c'");
    expect(source.content, contains("  foo(bar: 'c');"));
  });

  test('add second param single line', () {
    final source = _tempSourceFile(
      StringIndentation("""
        |void main() {
        |  foo(qwer: 'a');
        |}
        """).trimMargin(),
    );
    final fooMethod = source.findMethodInvocationByName('foo');
    setNamedParameter(source, fooMethod, name: 'bar', value: "'c'");
    expect(source.content, contains("  foo(qwer: 'a', bar: 'c');"));
  });

  test('add second param multi line', () {
    final source = _tempSourceFile(
      StringIndentation("""
        |void main() {
        |  foo(
        |    qwer: 'a',
        |  );
        |}
        """).trimMargin(),
    );
    final fooMethod = source.findMethodInvocationByName('foo');
    setNamedParameter(source, fooMethod, name: 'bar', value: "'c'");
    expect(
      source.content,
      contains("  foo(\n    qwer: 'a',\n    bar: 'c',\n  );"),
    );
  });
}

extension on ModifiableSourceFile {
  MethodInvocation findMethodInvocationByName(String name) {
    return analyze()
        .nodes
        .whereType<MethodInvocation>()
        .firstWhere((node) => node.methodName.name == name);
  }
}

ModifiableSourceFile _tempSourceFile(String content) {
  final dir = Directory.systemTemp.createTempSync('flutterw_sidekick_plugin');
  addTearDown(() => dir.deleteSync(recursive: true));
  final file = dir.file('source.dart')..createSync();
  file.writeAsStringSync(content);
  return ModifiableSourceFile(file);
}

ParsedUnitResult analyzeFile(File file) {
  final collection =
      AnalysisContextCollection(includedPaths: [file.absolute.path]);
  final context = collection.contextFor(file.absolute.path);
  final parsedUnit = context.currentSession.getParsedUnit(file.absolute.path)
      as ParsedUnitResult;
  return parsedUnit;
}
