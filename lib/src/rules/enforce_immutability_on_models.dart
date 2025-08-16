import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class EnforceImmutabilityOnModelsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'enforce_immutability_on_models',
    'Model fields should be final for predictable state.',
    correctionMessage: "Add 'final' to the field declaration.",
  );

  EnforceImmutabilityOnModelsRule()
      : super(
    name: 'enforce_immutability_on_models',
    description: 'Flags non-final fields in data model classes.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    // Register the visitor to check for class declarations.
    registry.addClassDeclaration(this, _ImmutabilityVisitor(this, context));
  }
}

/// The visitor for the `EnforceImmutabilityOnModelsRule`.
class _ImmutabilityVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _ImmutabilityVisitor(this.rule, this.context);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Simple way to identify a data model: a class with a constructor
    // that has at least one named parameter.
    final hasNamedConstructor = node.members.any(
          (member) => member is ConstructorDeclaration &&
          member.parameters.parameters.any((p) => p.isNamed),
    );

    if (!hasNamedConstructor) {
      return;
    }

    for (final member in node.members) {
      if (member is FieldDeclaration && !member.fields.isFinal) {
        member.fields.variables.forEach(rule.reportAtNode);
      }
    }
  }
}