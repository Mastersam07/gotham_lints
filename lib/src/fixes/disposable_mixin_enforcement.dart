import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class AddDisposableMixinFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind('dart.fix.addDisposableMixin', DartFixKindPriority.standard, 'Add `Disposable` mixin');

  AddDisposableMixinFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! ClassDeclaration) {
      return;
    }

    builder.addDartFileEdit(file, (builder) {
      final extendsClause = node.extendsClause;
      if (extendsClause != null) {
        // If there's an `extends` clause, insert the mixin after it.
        builder.addSimpleInsertion(extendsClause.end, ' with Disposable');
      } else {
        // If there's no `extends` clause, insert the mixin after the class name.
        builder.addSimpleInsertion(node.name.end, ' with Disposable');
      }
    });
  }
}
