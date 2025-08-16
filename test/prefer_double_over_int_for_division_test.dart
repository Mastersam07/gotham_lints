import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/prefer_double_over_int_for_division.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferDoubleOverIntForDivisionRuleTest);
  });
}

@reflectiveTest
class PreferDoubleOverIntForDivisionRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'prefer_double_over_int_for_division';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(PreferDoubleOverIntForDivisionRule());
    super.setUp();
  }

  Future<void> test_integer_division() async {
    await assertDiagnostics(
      r'''
void f() {
  var a = 10;
  var b = 3;
  var c = a / b;
}
''',
      [lint(48, 5)], // Faulty integer division starts at character 48 and spans 5 characters
    );
  }

  Future<void> test_explicit_integer_division() async {
    await assertNoDiagnostics(r'''
void f() {
  var a = 10;
  var b = 3;
  var c = a ~/ b;
}
''');
  }
}
