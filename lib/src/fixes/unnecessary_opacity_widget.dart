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
    'Replace Opacity with Image opacity parameter',
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

    if (childExpression is! InstanceCreationExpression) {
      return;
    }

    await builder.addDartFileEdit(file, (builder) {
      // Step 1: Delete "Opacity(opacity: X, child: " up to but not including the Image widget
      // Use the type name's begin token to ensure we keep "Image"
      final imageTypeBeginToken = childExpression.constructorName.type.beginToken;
      builder.addDeletion(range.startStart(node.beginToken, imageTypeBeginToken));

      // Step 2: Add the opacity parameter to the Image widget
      // Insert before the closing paren of the Image's argument list
      final imageClosingParen = childExpression.argumentList.rightParenthesis;
      if (childExpression.argumentList.arguments.isEmpty) {
        builder.addSimpleInsertion(imageClosingParen.offset, 'opacity: AlwaysStoppedAnimation($opacityValue)');
      } else {
        builder.addSimpleInsertion(imageClosingParen.offset, ', opacity: AlwaysStoppedAnimation($opacityValue)');
      }

      // Step 3: Delete from after the Image widget to the end of Opacity widget
      // This includes the closing paren, but preserve any trailing comma
      final imageEndToken = childExpression.endToken;
      final opacityEndToken = node.endToken;

      // Check if there's a trailing comma after the Opacity widget
      final nextToken = opacityEndToken.next;
      if (nextToken != null && nextToken.lexeme == ',') {
        // Delete from after Image to just before the trailing comma
        // This preserves the comma
        builder.addDeletion(range.startEnd(imageEndToken.next!, opacityEndToken));
      } else {
        // No trailing comma, delete from after Image to the end of Opacity
        builder.addDeletion(range.startEnd(imageEndToken.next!, opacityEndToken));
      }
    });
  }
}
