import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:gotham_lints/src/rules/future_without_async_await.dart';
import 'package:gotham_lints/src/rules/use_sizedbox_instead_container.dart';

final plugin = GothamLintsPlugin();

class GothamLintsPlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(UseSizedBoxInsteadOfContainerRule());
    registry.registerLintRule(FutureWithoutAsyncAwaitRule());

    registry.registerFixForRule(UseSizedBoxInsteadOfContainerRule.code, UseSizedBoxFix.new);
    registry.registerFixForRule(FutureWithoutAsyncAwaitRule.code, RemoveAwait.new);
  }
}
