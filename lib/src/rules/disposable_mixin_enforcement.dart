import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class DisposableMixinEnforcementRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'disposable_mixin_enforcement',
    'Classes with a `dispose` method should mix in `Disposable`.',
    correctionMessage: 'Add `with Disposable` to the class declaration.',
  );

  DisposableMixinEnforcementRule()
    : super(name: 'disposable_mixin_enforcement', description: 'Enforces a pattern for proper resource management.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addClassDeclaration(this, _DisposableVisitor(this, context));
  }
}

class _DisposableVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _DisposableVisitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final hasDisposeMethod = node.members.any((member) {
      if (member is MethodDeclaration) {
        return member.name.lexeme == 'dispose';
      }
      return false;
    });

    if (!hasDisposeMethod) {
      return;
    }

    final hasDisposableMixin = node.withClause?.mixinTypes.any((type) => type.name.lexeme == 'Disposable') ?? false;

    if (!hasDisposableMixin) {
      rule.reportAtNode(node);
    }
  }
}
