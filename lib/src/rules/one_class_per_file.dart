import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class OneClassPerFileRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'one_class_per_file',
    'A file should contain only one public top-level class.',
    correctionMessage: 'Move this class to its own file.',
  );

  OneClassPerFileRule()
      : super(
    name: 'one_class_per_file',
    description: 'Enforces that each file has only one public class.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addCompilationUnit(this, _OneClassPerFileVisitor(this, context));
  }
}

class _OneClassPerFileVisitor extends RecursiveAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _OneClassPerFileVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Find all top-level class declarations.
    final publicClasses = node.declarations
        .whereType<ClassDeclaration>()
        .where((declaration) => !declaration.name.lexeme.startsWith('_'))
        .toList();

    // If there is more than one public class, report an error on each one
    // after the first one.
    if (publicClasses.length > 1) {
      for (int i = 1; i < publicClasses.length; i++) {
        rule.reportAtNode(publicClasses[i]);
      }
    }
  }
}