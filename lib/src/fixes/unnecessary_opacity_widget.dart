import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:collection/collection.dart';

class UnnecessaryOpacityFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind(
    'dart.fix.unnecessaryOpacity',
    DartFixKindPriority.standard,
    'Replace Opacity with color property',
  );

  UnnecessaryOpacityFix({required super.context});

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

    // Get the `opacity` value and the `child` expression.
    final opacityArgument = node.argumentList.arguments.whereType<NamedExpression>().firstWhereOrNull(
      (e) => e.name.label.name == 'opacity',
    );
    final childArgument = node.argumentList.arguments.whereType<NamedExpression>().firstWhereOrNull(
      (e) => e.name.label.name == 'child',
    );

    if (opacityArgument == null || childArgument == null) {
      return;
    }

    final opacityValue = opacityArgument.expression.toString();
    final childExpression = childArgument.expression;

    builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(range.startEnd(node.beginToken, childExpression.beginToken));

      builder.addSimpleInsertion(childExpression.end, ', color: Colors.white.withOpacity($opacityValue)');

      final parent = node.parent;
      if (parent is ArgumentList) {
        builder.addDeletion(range.startEnd(node.endToken, node.endToken.next!));
      } else {
        builder.addDeletion(range.endEnd(node.endToken.previous!, node.endToken));
      }
    });
  }
}
