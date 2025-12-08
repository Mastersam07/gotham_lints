import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class ConvertToListViewBuilderFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind(
    'dart.fix.convertToListViewBuilder',
    DartFixKindPriority.standard,
    'Convert to ListView.builder',
  );

  ConvertToListViewBuilderFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! NamedExpression) {
      return;
    }

    final childrenArgument = node;
    final constructorInvocation = childrenArgument.parent?.parent;
    if (constructorInvocation is! InstanceCreationExpression) {
      return;
    }

    final childrenList = childrenArgument.expression;
    if (childrenList is! ListLiteral) {
      return;
    }

    builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(range.token(constructorInvocation.constructorName.type.name), 'ListView.builder');

      builder.addSimpleReplacement(
        range.startEnd(childrenArgument.beginToken, childrenArgument.endToken),
        '''itemCount: ${childrenList.length}, itemBuilder: (context, index) {
      // TODO: Replace with logic to build a single child.
      return const Placeholder();
    }''',
      );
    });
  }
}
