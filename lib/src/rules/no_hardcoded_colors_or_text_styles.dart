import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoHardcodedColorsOrTextStylesRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_hardcoded_colors_or_text_styles',
    'Avoid hardcoded Colors or TextStyles. Use theme-defined values.',
    correctionMessage: 'Use `Theme.of(context)` to get a theme-defined value.',
  );

  NoHardcodedColorsOrTextStylesRule()
    : super(name: 'no_hardcoded_colors_or_text_styles', description: 'Flags hardcoded Colors or TextStyles.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _HardcodedValuesVisitor(this, context));
  }
}

/// The visitor for the `NoHardcodedColorsOrTextStylesRule`.
class _HardcodedValuesVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _HardcodedValuesVisitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;

    if (typeName == 'Color' || typeName == 'TextStyle') {
      rule.reportAtNode(node);
    }
  }
}
