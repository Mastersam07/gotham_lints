import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class UseSizedBoxInsteadOfContainerRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'use_sized_box_instead_of_container',
    'Prefer using SizedBox for simple sizing over Container.',
    correctionMessage: "Replace with 'SizedBox' to improve performance.",
  );

  UseSizedBoxInsteadOfContainerRule()
    : super(
        name: 'use_sized_box_instead_of_container',
        description:
            'Flags `Container` widgets that can be replaced with `SizedBox`.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme != 'Container') {
      return;
    }

    bool hasOtherProperties = false;
    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedExpression) {
        continue;
      }
      final name = argument.name.label.name;
      if (name != 'width' && name != 'height' && name != 'key') {
        hasOtherProperties = true;
        break;
      }
    }

    if (!hasOtherProperties) {
      rule.reportAtNode(node);
    }
  }
}

class UseSizedBoxFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind(
    'dart.fix.useSizedBox',
    DartFixKindPriority.standard,
    'Replace with SizedBox',
  );

  UseSizedBoxFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! InstanceCreationExpression) {
      return;
    }
    final constructorName = node.constructorName.type.name;
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.token(constructorName), 'SizedBox');
    });
  }
}
