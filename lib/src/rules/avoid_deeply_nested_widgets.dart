import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidDeeplyNestedWidgetsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_deeply_nested_widgets',
    'Avoid deeply nested widget trees for better readability.',
    correctionMessage: 'Consider extracting a new widget from a portion of the tree.',
  );

  final int maxDepth;

  AvoidDeeplyNestedWidgetsRule({Map<String, Object?>? config})
    : maxDepth = _parseMaxDepth(config),
      super(name: 'avoid_deeply_nested_widgets', description: 'Flags excessively deep widget trees.');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addCompilationUnit(this, _DeepNestingVisitor(this, context));
  }

  static int _parseMaxDepth(Map<String, Object?>? config) {
    if (config == null) return 7;
    final value = config['max_depth'];
    if (value is int) {
      return value;
    }
    return 7;
  }
}

class _DeepNestingVisitor extends RecursiveAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;
  int _depth = 0;
  static const int _maxDepth = 7;

  _DeepNestingVisitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final parent = node.parent;
    // Check if the parent is also a widget creation expression.
    if (parent is NamedExpression && parent.name.label.name == 'child' ||
        parent is NamedExpression && parent.name.label.name == 'children' ||
        parent is ListLiteral) {
      _depth++;
      if (_depth > _maxDepth) {
        rule.reportAtNode(node);
      }
    }

    // Continue the traversal.
    super.visitInstanceCreationExpression(node);

    // Decrement the depth after visiting the children.
    if (parent is NamedExpression && parent.name.label.name == 'child' ||
        parent is NamedExpression && parent.name.label.name == 'children' ||
        parent is ListLiteral) {
      _depth--;
    }
  }
}
