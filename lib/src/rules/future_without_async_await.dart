import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class FutureWithoutAsyncAwaitRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'future_without_async_await',
    'Future-returning function should use `async` or handle the Future.',
    correctionMessage: "Consider adding the 'async' keyword to the function.",
  );

  FutureWithoutAsyncAwaitRule()
      : super(
    name: 'future_without_async_await',
    description: 'Warns about Future-returning functions that do not use `async` and have no `await`.',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addFunctionDeclaration(this, _AsyncAwaitVisitor(this, context));
    registry.addMethodDeclaration(this, _AsyncAwaitVisitor(this, context));
  }
}

class _AsyncAwaitVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _AsyncAwaitVisitor(this.rule, this.context);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkDeclaration(node);
  }

  void _checkDeclaration(Declaration node) {
    TypeAnnotation? returnType;
    if (node is FunctionDeclaration) {
      returnType = node.returnType;
    } else if (node is MethodDeclaration) {
      returnType = node.returnType;
    }

    final type = returnType?.type;
    if (type is! InterfaceType || type.element.name != 'Future') {
      return;
    }

    FunctionBody? body;
    if (node is FunctionDeclaration) {
      body = node.functionExpression.body;
    } else if (node is MethodDeclaration) {
      body = node.body;
    }

    if (body?.isAsynchronous ?? false) {
      return;
    }

    final hasAwaitVisitor = _HasAwaitVisitor();
    body?.accept(hasAwaitVisitor);

    if (!hasAwaitVisitor.hasAwait) {
      rule.reportAtNode(node);
    }
  }
}

/// A visitor to check for `await` expressions within a function body.
class _HasAwaitVisitor extends RecursiveAstVisitor<void> {
  bool hasAwait = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    hasAwait = true;
    super.visitAwaitExpression(node);
  }
}


/// A quick fix to remove the `await` keyword.
class RemoveAwait extends ResolvedCorrectionProducer {
  static const _removeAwaitKind = FixKind(
      'dart.fix.removeAwait', DartFixKindPriority.standard, "Remove the 'await' keyword");

  RemoveAwait({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _removeAwaitKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final awaitExpression = node;
    if (awaitExpression is AwaitExpression) {
      final awaitToken = awaitExpression.awaitKeyword;
      await builder.addDartFileEdit(file, (builder) {
        builder.addDeletion(range.startStart(awaitToken, awaitToken.next!));
      });
    }
  }
}
