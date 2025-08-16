import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoExportFromSrcRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_export_from_src',
    'Do not re-export from internal `src` files.',
    correctionMessage: 'Public library files should only export public APIs.',
  );

  NoExportFromSrcRule()
    : super(
        name: 'no_export_from_src',
        description: 'Discourages re-exporting internal src files in a public library.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addExportDirective(this, _ExportVisitor(this, context));
  }
}

class _ExportVisitor extends RecursiveAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _ExportVisitor(this.rule, this.context);

  @override
  void visitExportDirective(ExportDirective node) {
    // Get the path of the current file being analyzed.
    final currentPath = context.currentUnit!.file.path;
    // Get the URI of the exported file.
    final exportedUri = node.uri.stringValue;

    // Check if the current file is a public library file (not in a src folder)
    // and if the exported URI is from a `src` directory.
    if (!currentPath.contains('/src/') && exportedUri?.contains('/src/') == true) {
      // Report the lint on the URI of the export directive.
      rule.reportAtNode(node.uri);
    }
  }
}
