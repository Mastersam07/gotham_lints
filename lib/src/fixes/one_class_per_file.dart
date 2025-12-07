import 'dart:io';

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:path/path.dart' as path;

class OneClassPerFileFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind(
    'dart.fix.oneClassPerFile',
    DartFixKindPriority.standard,
    'Extract class to a separate file',
  );

  OneClassPerFileFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! ClassDeclaration) {
      return;
    }

    final className = node.name.lexeme;
    final fileName = _toSnakeCase(className);

    final currentFile = File(file);
    final currentDir = currentFile.parent;
    final newFilePath = path.join(currentDir.path, '$fileName.dart');

    final unit = node.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) {
      return;
    }

    final importsToInclude = <String>[];
    for (final directive in unit.directives) {
      if (directive is ImportDirective) {
        importsToInclude.add(utils.getNodeText(directive));
      }
    }

    final classSource = utils.getNodeText(node);

    final newFileContent = StringBuffer();

    for (final import in importsToInclude) {
      newFileContent.writeln(import);
    }

    if (importsToInclude.isNotEmpty) {
      newFileContent.writeln();
    }

    newFileContent.writeln(classSource);

    await builder.addDartFileEdit(newFilePath, (builder) => builder.addSimpleInsertion(0, newFileContent.toString()));

    await builder.addDartFileEdit(file, (builder) {
      final nodeToDelete = _getNodeWithSurroundingWhitespace(node);
      builder.addDeletion(nodeToDelete);

      final lastImport = unit.directives.whereType<ImportDirective>().lastOrNull;
      final importStatement = "import '$fileName.dart';";

      if (lastImport != null) {
        builder.addSimpleInsertion(lastImport.end, '\n$importStatement');
      } else {
        final firstDeclaration = unit.declarations.firstOrNull;
        if (firstDeclaration != null) {
          builder.addSimpleInsertion(0, '$importStatement\n\n');
        } else {
          builder.addSimpleInsertion(0, '$importStatement\n');
        }
      }
    });
  }

  SourceRange _getNodeWithSurroundingWhitespace(AstNode node) {
    final nodeRange = range.node(node);
    final content = utils.getNodeText(node.root as CompilationUnit);

    var end = nodeRange.end;

    var newlineCount = 0;
    while (end < content.length && newlineCount < 2) {
      final char = content[end];
      if (char == '\n') {
        end++;
        newlineCount++;
      } else if (char == ' ' || char == '\t' || char == '\r') {
        end++;
      } else {
        break;
      }
    }

    return range.startOffsetEndOffset(nodeRange.offset, end);
  }

  String _toSnakeCase(String className) {
    return className
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
  }
}
