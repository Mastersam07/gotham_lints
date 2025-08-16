import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class ConstOnlyOnLeafWidgetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'const_only_on_leaf_widgets',
    'Avoid `const` on non-leaf widgets. Apply it to the lowest possible widget.',
    correctionMessage: "Remove 'const' and apply it to a leaf widget.",
  );

  ConstOnlyOnLeafWidgetsRule()
    : super(name: 'const_only_on_leaf_widgets', description: 'Warns against using `const` on non-leaf widgets.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _ConstOnLeafVisitor(this, context));
  }
}

class _ConstOnLeafVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _ConstOnLeafVisitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!node.isConst) {
      return;
    }

    bool hasContainerProperty = false;
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression) {
        final name = argument.name.label.name;
        if (name == 'child' || name == 'children') {
          hasContainerProperty = true;
          break;
        }
      }
    }

    if (hasContainerProperty) {
      rule.reportAtNode(node);
    }
  }
}
