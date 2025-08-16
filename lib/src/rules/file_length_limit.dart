import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class FileLengthRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'file_length_limit',
    'File is too long. Consider splitting it into smaller files.',
    correctionMessage: 'Refactor the file to be shorter.',
  );

  FileLengthRule() : super(name: 'file_length_limit', description: 'Flags files that exceed a maximum line count.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addCompilationUnit(this, _FileLengthVisitor(this, context));
  }
}

class _FileLengthVisitor extends RecursiveAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  static const int _maxLines = 500;

  _FileLengthVisitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final lineCount = node.lineInfo.lineCount;

    if (lineCount > _maxLines) {
      // Report the lint on the entire file.
      rule.reportAtNode(node);
    }
  }
}
