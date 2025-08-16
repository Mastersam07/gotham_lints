import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoPrivatePropertiesInPublicApiRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_private_properties_in_public_api',
    'Avoid exposing private types in public APIs.',
    correctionMessage: 'Refactor to not use a private type in a public method signature.',
  );

  NoPrivatePropertiesInPublicApiRule()
    : super(name: 'no_private_properties_in_public_api', description: 'Flags private types exposed in a public API.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodDeclaration(this, _PublicApiVisitor(this, context));
  }
}

class _PublicApiVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _PublicApiVisitor(this.rule, this.context);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme.startsWith('_')) {
      return;
    }

    final returnType = node.returnType;
    if (returnType is NamedType && returnType.name.lexeme.startsWith('_')) {
      rule.reportAtNode(returnType);
    }

    for (final parameter in node.parameters?.parameters ?? []) {
      final typeAnnotation = parameter.type;
      if (typeAnnotation is NamedType && typeAnnotation.name.lexeme.startsWith('_')) {
        rule.reportAtNode(typeAnnotation);
      }
    }
  }
}
