// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:gotham_lints/src/rules/future_without_async_await.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FutureWithoutAsyncAwaitRuleTest);
  });
}

@reflectiveTest
class FutureWithoutAsyncAwaitRuleTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'future_without_async_await';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(FutureWithoutAsyncAwaitRule());
    super.setUp();
  }

  Future<void> test_future_returning_function_without_async() async {
    await assertDiagnostics(
      r'''
import 'dart:async';
Future<void> f() {
  return Future.value();
}
''',
      [lint(21, 45)], // Function starts at character 21 and spans 45 characters
    );
  }

  Future<void> test_future_returning_async_function() async {
    await assertNoDiagnostics(r'''
import 'dart:async';
Future<void> f() async {
  return Future.value();
}
''');
  }

  Future<void> test_future_returning_function_with_await() async {
    await assertNoDiagnostics(r'''
import 'dart:async';
Future<void> f() async {
  await Future.value();
}
''');
  }

  Future<void> test_non_future_function() async {
    await assertNoDiagnostics(r'''
void f() {
  print('hello');
}
''');
  }
}
