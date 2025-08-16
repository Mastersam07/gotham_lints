import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/no_private_properties_in_public_api.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoPrivatePropertiesInPublicApiRuleTest);
  });
}

@reflectiveTest
class NoPrivatePropertiesInPublicApiRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'no_private_properties_in_public_api';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(NoPrivatePropertiesInPublicApiRule());
    super.setUp();
  }

  Future<void> test_public_method_with_private_return() async {
    await assertDiagnostics(
      r'''
class MyClass {
  _PrivateType getPrivate() => _PrivateType();
}
class _PrivateType {}
''',
      [lint(18, 12)], // _PrivateType at Character 18 and spans 12 characters
    );
  }

  Future<void> test_public_method_with_private_parameter() async {
    await assertDiagnostics(
      r'''
class MyClass {
  void takePrivate(_PrivateType value) {}
}
class _PrivateType {}
''',
      [lint(35, 12)], // _PrivateType at Character 35 and spans 12 characters
    );
  }

  Future<void> test_public_method_with_public_types() async {
    await assertNoDiagnostics(r'''
class MyClass {
  void takePublic(String value) {}
}
''');
  }
}
