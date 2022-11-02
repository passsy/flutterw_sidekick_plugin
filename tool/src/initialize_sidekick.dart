import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:sidekick_core/sidekick_core.dart';

import 'modifiable_source_file.dart';

/// Finds the [initializeSidekick] method and sets the sdk path
void addFlutterSdkPath(File file, String path) {
  final ModifiableSourceFile source = ModifiableSourceFile(file);
  final initializeSidekickMethod = source
      .analyze()
      .nodes
      .whereType<MethodInvocation>()
      .firstWhere((node) => node.methodName.name == 'initializeSidekick');
  setNamedParameter(
    source,
    initializeSidekickMethod,
    name: 'flutterSdkPath',
    value: path,
  );
  source.flush();
}

void registerSdkInitializer(File file, String block) {
  final ModifiableSourceFile source = ModifiableSourceFile(file);
  final initializeSidekickMethod = source
      .analyze()
      .nodes
      .whereType<MethodInvocation>()
      .firstWhere((node) => node.methodName.name == 'initializeSidekick');

  final methodEnd = initializeSidekickMethod.semicolon!.end;
  source.addModification(CodeModification(methodEnd, methodEnd, '\n  $block'));
  source.flush();
}

/// Adds or updates a named parameter of [methodInvocation]
void setNamedParameter(
  ModifiableSourceFile sourceFile,
  MethodInvocation methodInvocation, {
  required String name,
  required String value,
}) {
  final argumentList = methodInvocation.argumentList;
  final hasArguments = argumentList.arguments.isNotEmpty;
  final NamedExpression? existingArgument =
      argumentList.arguments.firstOrNullWhere(
    (arg) => arg is NamedExpression && arg.name.label.name == name,
  ) as NamedExpression?;
  final commaToken = argumentList.rightParenthesis.previous;
  final hasTrailingComma = commaToken?.type == TokenType.COMMA;
  final insertPoint = argumentList.rightParenthesis.offset;
  Expression? previousArgument = argumentList.arguments.lastOrNull;
  if (existingArgument != null) {
    final existingIndex = argumentList.arguments.indexOf(existingArgument);
    if (existingIndex > 0) {
      previousArgument = argumentList.arguments[existingIndex - 1];
    }
  }

  if (existingArgument == null) {
    final param = '$name: $value';

    if (hasTrailingComma && previousArgument != null) {
      final int indentation = () {
        final unit = sourceFile.analyze().unit;
        final beginToken = previousArgument!.offset;
        final lineInfo = unit.lineInfo;
        final line = lineInfo.getLocation(beginToken).lineNumber;
        final lineStart = lineInfo.getOffsetOfLine(line - 1);
        final indent = beginToken - lineStart;
        return indent;
      }();
      final spaces = ' ' * indentation;
      sourceFile.addModification(
        CodeModification(
          commaToken!.end,
          commaToken.end,
          '\n$spaces$param,',
        ),
      );
    } else {
      sourceFile.addModification(
        CodeModification(
          insertPoint,
          insertPoint,
          '${hasArguments ? ', ' : ''}$param',
        ),
      );
    }
  } else {
    sourceFile.addModification(
      CodeModification(
        existingArgument.offset,
        existingArgument.end,
        '$name: $value',
      ),
    );
  }
}

extension on CompilationUnit {
  List<AstNode> get nodes {
    final List<AstNode> list = [];
    final visitor = _AllNodesVisitor(
      onNode: (node) {
        list.add(node);
      },
    );
    visitor.visitAllNodes(this);
    return list;
  }
}

extension AllNodes on ParsedUnitResult {
  List<AstNode> get nodes => unit.nodes;
}

class _AllNodesVisitor extends BreadthFirstVisitor<void> {
  final void Function(AstNode) onNode;

  _AllNodesVisitor({required this.onNode});

  @override
  void visitNode(AstNode node) {
    onNode(node);
    super.visitNode(node);
  }
}

extension on Token {
  Iterable<Token> nextTokens() sync* {
    Token? token = this;
    while (token != null) {
      token = token.next;
      if (token != null) {
        yield token;
      }
    }
  }
}

extension on MethodInvocation {
  Token? get semicolon => endToken
      .nextTokens()
      .firstOrNullWhere((token) => token.type == TokenType.SEMICOLON);
}
