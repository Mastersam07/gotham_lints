// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/avoid_unhandled_future.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnhandledFutureRuleTest);
  });
}

@reflectiveTest
class AvoidUnhandledFutureRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'avoid_unhandled_future';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(AvoidUnhandledFutureRule());
    super.setUp();
  }

  Future<void> test_unhandled_future() async {
    await assertDiagnostics(
      r'''
import 'dart:async';
void f() {
  Future.value();
}
''',
      [lint(34, 15)], // Future starts at character 34 and spans 15 characters
    );
  }

  Future<void> test_awaited_future() async {
    await assertNoDiagnostics(r'''
import 'dart:async';
void f() async {
  await Future.value();
}
''');
  }
}
