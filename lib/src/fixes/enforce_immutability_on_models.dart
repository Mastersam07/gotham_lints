import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class EnforceFinalFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind('dart.fix.enforceFinal', DartFixKindPriority.standard, 'Add `final` keyword');

  EnforceFinalFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! VariableDeclaration) {
      return;
    }

    final fieldDeclaration = node.thisOrAncestorOfType<FieldDeclaration>();
    if (fieldDeclaration == null) {
      return;
    }

    if (fieldDeclaration.fields.isFinal) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      final fields = fieldDeclaration.fields;

      final typeAnnotation = fields.type;
      if (typeAnnotation != null) {
        builder.addSimpleInsertion(typeAnnotation.offset, 'final ');
      } else {
        builder.addSimpleInsertion(fields.beginToken.offset, 'final ');
      }
    });
  }
}
