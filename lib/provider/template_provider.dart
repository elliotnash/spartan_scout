import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jsonc/jsonc.dart';
import 'package:spartan_scout/model/template.dart';

class TemplatesNotifier extends StateNotifier<List<Template>> {
  TemplatesNotifier() : super([]) {
    _loadAssets();
  }
  Future<void> _loadAssets() async {
    String manifestJson = await rootBundle.loadString('AssetManifest.json');
    List<String> templates = jsonc.decode(manifestJson).keys.where(
        (String key) =>
            key.startsWith('assets/templates') &&
            (key.endsWith(".jsonc") || key.endsWith(".json"))).toList();
    print(templates);
  }

  void loadJson(Map<String, Object?> json) {}
}

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, List<Template>>(
        (ref) => TemplatesNotifier());
