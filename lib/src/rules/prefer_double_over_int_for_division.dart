import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class PreferDoubleOverIntForDivisionRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_double_over_int_for_division',
    'Use `~/` for integer division or explicitly cast to a double.',
    correctionMessage: 'Replace `/` with `~/` for integer division.',
  );

  PreferDoubleOverIntForDivisionRule()
    : super(
        name: 'prefer_double_over_int_for_division',
        description: 'Flags division of integers using `/` instead of `~/`.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addBinaryExpression(this, _DivisionVisitor(this, context));
  }
}

class _DivisionVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _DivisionVisitor(this.rule, this.context);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    // Check if the operator is `/`.
    if (node.operator.lexeme != '/') {
      return;
    }

    // Get the static types of the operands.
    final leftType = node.leftOperand.staticType;
    final rightType = node.rightOperand.staticType;

    // Check if both operands are of type `int`.
    if (leftType is InterfaceType &&
        leftType.element.name == 'int' &&
        rightType is InterfaceType &&
        rightType.element.name == 'int') {
      rule.reportAtNode(node);
    }
  }
}
