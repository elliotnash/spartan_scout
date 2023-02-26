import 'package:flutter/services.dart';
import 'package:json5/json5.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spartan_scout/model/template.dart';

part 'template_provider.g.dart';

@riverpod
class Templates extends _$Templates {
  @override
  Future<Map<String, Template>> build() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final templates = await Future.wait(
        (JSON5.parse(manifestJson).keys as Iterable<String>)
            .where((key) =>
                key.startsWith('assets/templates') &&
                (key.endsWith(".jsonc") || key.endsWith(".json") || key.endsWith(".json5")))
            .map((String json) async => Template.fromJson(
                JSON5.parse(await rootBundle.loadString(json)))));
    // todo load templates from storage
    return {for (var template in templates) template.name: template};
  }

  Future<void> loadJson(Map<String, Object?> json) async {
    final template = Template.fromJson(json);
    state = AsyncValue.data({...(await future), template.name: template});
  }
}

@riverpod
class SelectedTemplate extends _$SelectedTemplate {
  final _defaultTemplate = rootBundle.loadString('assets/templates/default');
  String? _selected;
  String? get selectedTemplate => _selected;

  @override
  Future<Template> build() async {
    var templates = await ref.watch(templatesProvider.future);
    return templates[_selected ?? await _defaultTemplate]!;
  }
  Future<void> select(String name) async {
    state = await AsyncValue.guard(() async {
      _selected = name;
      final templates = await ref.read(templatesProvider.future);
      return templates[_selected]!;
    });
  }
}
