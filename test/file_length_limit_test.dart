import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/file_length_limit.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FileLengthRuleTest);
  });
}

@reflectiveTest
class FileLengthRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'file_length_limit';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(FileLengthRule());
    super.setUp();
  }

  Future<void> test_long_file() async {
    final longContent = List.generate(501, (index) => '// line $index').join('\n');
    await assertDiagnostics(longContent, [
      lint(
        0,
        longContent.length,
        messageContains: FileLengthRule.code.problemMessage,
        correctionContains: FileLengthRule.code.correctionMessage,
      ),
    ]);
  }

  Future<void> test_short_file() async {
    final shortContent = List.generate(100, (index) => '// line $index').join('\n');
    await assertNoDiagnostics(shortContent);
  }
}
