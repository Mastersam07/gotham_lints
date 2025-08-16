import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';

class UnnecessaryOpacityWidgetRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'unnecessary_opacity_widget',
    'Avoid using Opacity widget for single child widgets. Apply it to the child\'s color property.',
    correctionMessage: "Replace with the child widget's color property.",
  );

  UnnecessaryOpacityWidgetRule()
      : super(
    name: 'unnecessary_opacity_widget',
    description: 'Flags Opacity widgets that are not necessary.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _OpacityVisitor(this, context));
  }
}

/// The visitor for the `UnnecessaryOpacityWidgetRule`.
class _OpacityVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _OpacityVisitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme != 'Opacity') {
      return;
    }

    final childArgument = node.argumentList.arguments.whereType<NamedExpression>()
        .firstWhereOrNull((e) => e.name.label.name == 'child');

    if (childArgument == null) {
      return;
    }

    // Check if the `child` is an `Image` widget.
    final childExpression = childArgument.expression;
    if (childExpression is! InstanceCreationExpression || childExpression.constructorName.type.name.lexeme != 'Image') {
      return;
    }

    // If all conditions are met, report the lint on the `Opacity` widget.
    rule.reportAtNode(node);
  }
}
