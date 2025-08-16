import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class UseSizedBoxInsteadOfContainerRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'use_sized_box_instead_of_container',
    'Prefer using SizedBox for simple sizing over Container.',
    correctionMessage: "Replace with 'SizedBox' to improve performance.",
  );

  UseSizedBoxInsteadOfContainerRule()
    : super(
        name: 'use_sized_box_instead_of_container',
        description: 'Flags `Container` widgets that can be replaced with `SizedBox`.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme != 'Container') {
      return;
    }

    bool hasOtherProperties = false;
    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedExpression) {
        continue;
      }
      final name = argument.name.label.name;
      if (name != 'width' && name != 'height' && name != 'key') {
        hasOtherProperties = true;
        break;
      }
    }

    if (!hasOtherProperties) {
      rule.reportAtNode(node);
    }
  }
}
