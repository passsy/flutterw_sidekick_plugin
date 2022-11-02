import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:sidekick_core/sidekick_core.dart';

class ModifiableSourceFile {
  final File file;

  ModifiableSourceFile(this.file);

  String get contentOnDisk => file.readAsStringSync();

  final List<CodeModification> _modifications = [];

  void addModification(CodeModification modification) {
    _modifications.add(modification);
    // delete cache
    _unit = null;
  }

  String get content {
    String text = contentOnDisk;
    for (final CodeModification modification in _modifications) {
      final update = text.replaceRange(
        modification.startOffset,
        modification.endOffset,
        modification.replacement,
      );
      text = update;
    }
    return text;
  }

  Directory? _tempDir;
  File? _tempFile;

  void _updateTempFile() {
    _tempDir ??=
        Directory.systemTemp.createTempSync('flutterw_sidekick_plugin');
    _tempFile ??= _tempDir!.file('source.dart')..createSync();
    _tempFile!.writeAsStringSync(content);
  }

  void dispose() {
    _tempDir?.deleteSync(recursive: true);
  }

  void flush() {
    file.writeAsStringSync(content);
    _unit = null;
    _modifications.clear();
    if (_tempFile != null && _tempFile!.existsSync()) {
      _tempFile!.deleteSync();
    }
  }

  ParsedUnitResult? _unit;

  ParsedUnitResult analyze() {
    if (_unit != null) {
      return _unit!;
    }

    // create a temp file that is observed by the analysis server,
    // in memory source code doesn't do it
    _updateTempFile();

    final file = _tempFile!;
    final collection =
        AnalysisContextCollection(includedPaths: [file.absolute.path]);
    final context = collection.contextFor(file.absolute.path);
    final parsedUnit = context.currentSession.getParsedUnit(file.absolute.path)
        as ParsedUnitResult;
    return parsedUnit;
  }
}

/// A modification of [ModifiableSourceFile] that operates on
/// [ModifiableSourceFile.content], **not** [ModifiableSourceFile.contentOnDisk].
class CodeModification {
  final int startOffset;
  final int endOffset;
  final String replacement;

  CodeModification(
    this.startOffset,
    this.endOffset,
    this.replacement,
  );
}
