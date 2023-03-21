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

  Future<ScoutingData> scoutingDataFromSimpleJson(Map<String, dynamic> simpleData) async {
    final templateUuid = simpleData["templateUuid"];
    final templateVersion = simpleData["templateVersion"];
    final type = ScoutingType.values.where((e) => e.name == simpleData["type"]).first;
    final templates = (await future).values.where((e) => e.uuid == templateUuid && e.version == templateVersion);
    late final Template template;
    if (templates.isEmpty) {
      template = await fetchTemplate(
        uuid: templateUuid,
        version: templateVersion,
      );
    } else {
      template = templates.first;
    }

    final data = template.newScoutingData(type);
    data.uuid = simpleData["uuid"];
    data.templateUuid = templateUuid;
    data.templateVersion = templateVersion;
    data.type = type;
    data.created = DateTime.fromMillisecondsSinceEpoch(simpleData["created"]);
    data.updated = DateTime.fromMillisecondsSinceEpoch(simpleData["updated"]);
    if (simpleData["storedAt"] != null) {
      data.storedAt = DateTime.fromMillisecondsSinceEpoch(simpleData["storedAt"]);
    }

    final List<TemplateEntry> entries = [];
    for (final entry in data.data) {
      if (entry.name != null) {
        final value = simpleData["data"][entry.name];
        if (value != null) {
          if (entry is TextEntry) {
            entry.value = value.toString();
          } else if (entry is CheckboxEntry) {
            entry.value = value;
          } else if (entry is CounterEntry) {
            entry.value = value;
          }
        }
      }
      entries.add(entry);
    }
    data.data = entries;

    return data;
  }
}
