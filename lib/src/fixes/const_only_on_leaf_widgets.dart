import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class RemoveConstFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind('dart.fix.removeConst', DartFixKindPriority.standard, 'Remove `const` keyword');

  RemoveConstFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! InstanceCreationExpression) {
      return;
    }

    final constToken = node.keyword;
    if (constToken == null || constToken.lexeme != 'const') {
      return;
    }

    builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.endEnd(constToken, constToken.next!), '');
    });
  }
}
