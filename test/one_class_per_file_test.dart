import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/one_class_per_file.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OneClassPerFileRuleTest);
  });
}

@reflectiveTest
class OneClassPerFileRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'one_class_per_file';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(OneClassPerFileRule());
    super.setUp();
  }

  Future<void> test_multiple_public_classes() async {
    await assertDiagnostics(
      r'''
class MyClass {}
class OtherClass {}
''',
      [
        lint(
          17,
          19,
          messageContains: OneClassPerFileRule.code.problemMessage,
          correctionContains: OneClassPerFileRule.code.correctionMessage,
        ),
      ], // Extra public class at character 17 and spans 19 characters
    );
  }

  Future<void> test_one_public_class() async {
    await assertNoDiagnostics(r'''
class MyClass {}
''');
  }

  Future<void> test_public_and_private_class() async {
    await assertNoDiagnostics(r'''
class MyClass {}
class _MyPrivateClass {}
''');
  }
}
