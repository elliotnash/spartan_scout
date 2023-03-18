import 'package:json5/json5.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';
import 'package:spartan_scout/provider/dio_provider.dart';

part 'template_provider.g.dart';

@riverpod
class Templates extends _$Templates {
  late final StoreRef<String, Map<String, dynamic>> store;
  @override
  Future<Map<String, Template>> build() async {
    store = StoreRef("templates");
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.find(db);
    // fetch default template
    fetchTemplate();
    return {
      for (final e in data)
        e.key: Template.fromJson(e.value)
    };
    // return data.map((e) => Template.fromJson(e.value)).toList();
    // final manifestJson = await rootBundle.loadString('AssetManifest.json');
    // final templates = await Future.wait(
    //     (JSON5.parse(manifestJson).keys as Iterable<String>)
    //         .where((key) =>
    //             key.startsWith('assets/templates') &&
    //             (key.endsWith(".jsonc") || key.endsWith(".json") || key.endsWith(".json5")))
    //         .map((String json) async => Template.fromJson(
    //             JSON5.parse(await rootBundle.loadString(json)))));
    // // todo load templates from storage
    // return {for (var template in templates) template.name: template};
  }

  Future<Template> get({String? uuid, int? version}) async {
    final key = (uuid != null && version != null) ? "$uuid:$version" : "default";
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.record(key).get(db);
    if (data != null) {
      return Template.fromJson(data);
    }
    return fetchTemplate(uuid: uuid, version: version);
  }

  Future<Template> fetchTemplate({String? uuid, int? version}) async {
    final res = await ref.read(scoutingDioProvider).get(
      "$kBaseUrl/template",
      queryParameters: {
        if (uuid != null)
          "uuid": uuid,
        if (version != null)
          "version": version,
      }
    );
    final template = Template.fromJson(JSON5.parse(res.data));
    final db = await ref.read(scoutingDatabaseProvider.future);
    final key = (uuid == null && version == null) ? "default" : "${template.uuid}:${template.version}";
    await store.record(key).put(db, template.toJson());
    state = AsyncValue.data({
      ...(await future),
      key: template
    });
    return template;
  }
}
