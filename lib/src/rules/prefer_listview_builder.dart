import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';


class PreferListViewBuilderRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_listview_builder',
    'Prefer ListView.builder for lists with many children.',
    correctionMessage: "Convert to `ListView.builder` for better performance.",
  );

  PreferListViewBuilderRule()
      : super(
    name: 'prefer_listview_builder',
    description: 'Flags ListView widgets with hardcoded children.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _ListViewVisitor(this, context));
  }
}

/// The visitor for the `PreferListViewBuilderRule`.
class _ListViewVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _ListViewVisitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // We only care about `ListView` and not `ListView.builder`, etc.
    final constructorName = node.constructorName.name?.name;
    if (node.constructorName.type.name.lexeme != 'ListView' || constructorName != null) {
      return;
    }

    final childrenArgument = node.argumentList.arguments.whereType<NamedExpression>()
        .firstWhereOrNull((e) => e.name.label.name == 'children');

    if (childrenArgument != null) {
      rule.reportAtNode(childrenArgument);
    }
  }
}