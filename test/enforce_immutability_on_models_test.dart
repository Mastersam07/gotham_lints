// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/enforce_immutability_on_models.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EnforceImmutabilityOnModelsRuleTest);
  });
}

@reflectiveTest
class EnforceImmutabilityOnModelsRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'enforce_immutability_on_models';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(EnforceImmutabilityOnModelsRule());
    super.setUp();
  }

  Future<void> test_model_with_non_final_field() async {
    await assertDiagnostics(
      r'''
class User {
  String name;
  User({required this.name});
}
''',
      [lint(22, 4)],
    );
  }

  Future<void> test_model_with_multiple_non_final_field() async {
    await assertDiagnostics(
      r'''
class User {
  String name;
  int age;
  User({required this.name, required this.age});
}
''',
      [lint(22, 4), lint(34, 3)],
    );
  }

  Future<void> test_model_with_final_field() async {
    await assertNoDiagnostics(r'''
class User {
  final String name;
  User({required this.name});
}
''');
  }
}
