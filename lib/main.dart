import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:gotham_lints/src/fixes/avoid_unhandled_future.dart';
import 'package:gotham_lints/src/fixes/disposable_mixin_enforcement.dart';
import 'package:gotham_lints/src/fixes/enforce_immutability_on_models.dart';
import 'package:gotham_lints/src/fixes/future_without_async_await.dart';
import 'package:gotham_lints/src/fixes/no_private_properties_in_public_api.dart';
import 'package:gotham_lints/src/fixes/prefer_double_over_int_for_division.dart';
import 'package:gotham_lints/src/fixes/prefer_listview_builder.dart';
import 'package:gotham_lints/src/fixes/unnecessary_opacity_widget.dart';
import 'package:gotham_lints/src/fixes/use_sizedbox_instead_container.dart';
import 'package:gotham_lints/src/rules/avoid_deeply_nested_widgets.dart';
import 'package:gotham_lints/src/rules/avoid_unhandled_future.dart';
import 'package:gotham_lints/src/rules/disposable_mixin_enforcement.dart';
import 'package:gotham_lints/src/rules/enforce_immutability_on_models.dart';
import 'package:gotham_lints/src/rules/file_length_limit.dart';
import 'package:gotham_lints/src/rules/future_without_async_await.dart';
import 'package:gotham_lints/src/rules/no_export_from_src.dart';
import 'package:gotham_lints/src/rules/no_hardcoded_colors_or_text_styles.dart';
import 'package:gotham_lints/src/rules/no_private_properties_in_public_api.dart';
import 'package:gotham_lints/src/rules/prefer_double_over_int_for_division.dart';
import 'package:gotham_lints/src/rules/prefer_listview_builder.dart';
import 'package:gotham_lints/src/rules/unnecessary_opacity_widget.dart';
import 'package:gotham_lints/src/rules/use_sizedbox_instead_container.dart';

final plugin = GothamLintsPlugin();

class GothamLintsPlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    registry
      ..registerLintRule(UseSizedBoxInsteadOfContainerRule())
      ..registerLintRule(FutureWithoutAsyncAwaitRule())
      ..registerLintRule(PreferListViewBuilderRule())
      ..registerLintRule(UnnecessaryOpacityWidgetRule())
      ..registerLintRule(NoHardcodedColorsOrTextStylesRule())
      ..registerLintRule(PreferDoubleOverIntForDivisionRule())
      ..registerLintRule(EnforceImmutabilityOnModelsRule())
      ..registerLintRule(AvoidUnhandledFutureRule())
      ..registerLintRule(NoPrivatePropertiesInPublicApiRule())
      ..registerLintRule(DisposableMixinEnforcementRule())
      ..registerLintRule(AvoidDeeplyNestedWidgetsRule())
      ..registerLintRule(FileLengthRule())
      ..registerLintRule(NoExportFromSrcRule())
      ..registerFixForRule(UseSizedBoxInsteadOfContainerRule.code, UseSizedBoxFix.new)
      ..registerFixForRule(FutureWithoutAsyncAwaitRule.code, RemoveAwait.new)
      ..registerFixForRule(PreferListViewBuilderRule.code, ConvertToListViewBuilderFix.new)
      ..registerFixForRule(UnnecessaryOpacityWidgetRule.code, UnnecessaryOpacityFix.new)
      ..registerFixForRule(PreferDoubleOverIntForDivisionRule.code, PreferIntegerDivisionFix.new)
      ..registerFixForRule(EnforceImmutabilityOnModelsRule.code, EnforceFinalFix.new)
      ..registerFixForRule(AvoidUnhandledFutureRule.code, AddAwaitFix.new)
      ..registerFixForRule(NoPrivatePropertiesInPublicApiRule.code, NoPrivatePropertiesInPublicApiFix.new)
      ..registerFixForRule(DisposableMixinEnforcementRule.code, AddDisposableMixinFix.new);
  }
}
