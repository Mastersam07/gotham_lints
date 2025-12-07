import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoFutureInBuildMethodRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_future_in_build_method',
    'Avoid calling functions that return a Future in a build method.',
    correctionMessage: 'Wrap the Future call in a FutureBuilder or handle the state outside of the build method.',
  );

  NoFutureInBuildMethodRule()
    : super(
        name: 'no_future_in_build_method',
        description: 'Flags asynchronous operations in build methods to prevent infinite rebuilds.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _NoFutureInBuildMethodVisitor(this, context));
  }
}

class _NoFutureInBuildMethodVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _NoFutureInBuildMethodVisitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final parentMethod = node.thisOrAncestorOfType<MethodDeclaration>();
    if (parentMethod == null) {
      return;
    }

    if (parentMethod.name.lexeme != 'build') {
      return;
    }

    final returnType = node.staticType;
    if (returnType != null && returnType.isDartAsyncFuture) {
      rule.reportAtNode(node);
    }
  }
}
