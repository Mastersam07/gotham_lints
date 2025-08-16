import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

class AvoidUnhandledFutureRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_unhandled_future',
    'A Future is not awaited or explicitly handled.',
    correctionMessage: 'Consider awaiting the Future.',
  );

  AvoidUnhandledFutureRule()
    : super(name: 'avoid_unhandled_future', description: 'Warns when a Future is not awaited or handled.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addExpressionStatement(this, _UnhandledFutureVisitor(this, context));
  }
}

class _UnhandledFutureVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _UnhandledFutureVisitor(this.rule, this.context);

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    final expression = node.expression;
    // Check if the expression returns a Future.
    if (expression.staticType is InterfaceType && (expression.staticType as InterfaceType).isDartAsyncFuture) {
      if (expression is! AwaitExpression) {
        rule.reportAtNode(node);
      }
    }
  }
}
