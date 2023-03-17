import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spartan_scout/provider/template_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

part 'template.freezed.dart';
part 'template.g.dart';

const uuidGen = Uuid();

@Freezed(makeCollectionsUnmodifiable: false)
class Template with _$Template {
  const Template._();
  const factory Template({
    required String name,
    required String uuid,
    required int version,
    required TemplateTab pit,
    required TemplateTab match,
  }) = _Template;

  ScoutingData newScoutingData(ScoutingType type) {
    return ScoutingData(
        uuid: uuidGen.v1(),
        templateUuid: uuid,
        templateVersion: version,
        type: type,
        created: DateTime.now(),
        updated: DateTime.now(),
        data: [
          for (final entry in (type == ScoutingType.pit ? pit : match).entries)
            entry.copyWith()
        ]);
  }

  factory Template.fromJson(Map<String, Object?> json) =>
      _$TemplateFromJson(json);
}

enum ScoutingType { pit, match }

@freezed
class TemplateTab with _$TemplateTab {
  const TemplateTab._();
  const factory TemplateTab({
    required String title,
    required List<TemplateEntry> entries,
  }) = _TemplateTab;

  factory TemplateTab.fromJson(Map<String, Object?> json) =>
      _$TemplateTabFromJson(json);
}

@Freezed(
  addImplicitFinal: false,
  makeCollectionsUnmodifiable: false,
)
class ScoutingData with _$ScoutingData {
  const ScoutingData._();
  factory ScoutingData({
    required String uuid,
    required String templateUuid,
    required int templateVersion,
    required ScoutingType type,
    required DateTime created,
    required DateTime updated,
    DateTime? storedAt,
    required List<TemplateEntry> data,
  }) = _ScoutingData;

  bool isSynced() {
    return storedAt == null ? false : storedAt!.isAfter(updated);
  }

  factory ScoutingData.fromJson(Map<String, dynamic> json) =>
      _$ScoutingDataFromJson(json);

  static Future<ScoutingData> fromSimpleJson(Map<String, dynamic> simpleData, Ref ref) async {
    final templateUuid = simpleData["templateUuid"];
    final templateVersion = simpleData["templateVersion"];
    final type = ScoutingType.values.where((e) => e.name == simpleData["type"]).first;
    final templates = (await ref.read(templatesProvider.future)).values.where((e) => e.uuid == templateUuid && e.version == templateVersion);
    late final Template template;
    if (templates.isEmpty) {
      template = await ref.read(templatesProvider.notifier).fetchTemplate(
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

  Map<String, Object?> toJsonSimple() {
    return {
      "uuid": uuid,
      "templateUuid": templateUuid,
      "templateVersion": templateVersion,
      "type": type.name,
      "created": created.millisecondsSinceEpoch,
      "updated": updated.millisecondsSinceEpoch,
      if (storedAt != null)
        "storedAt": storedAt!.millisecondsSinceEpoch,
      "data": {
        for (final entry
            in data.map((e) => e.toJson()).where((e) => e["value"] != null))
          entry["name"]: entry["value"],
      },
    };
  }
}

enum EntryType {
  section,
  spacer,
  text,
  checkbox,
  counter,
  picture,
}

@Freezed(
  unionKey: 'type',
  addImplicitFinal: false,
  makeCollectionsUnmodifiable: false,
)
class TemplateEntry with _$TemplateEntry {
  factory TemplateEntry({
    String? name,
    required EntryType type,
    dynamic value,
    // TODO whats this
    @Default(false) bool required,
  }) = UndefinedEntry;

  factory TemplateEntry.section({
    required String name,
    required EntryType type,
    required String prompt,
    @Default(false) bool required,
  }) = SectionEntry;

  factory TemplateEntry.spacer({
    String? name,
    required EntryType type,
    @Default(false) bool required,
  }) = SpacerEntry;

  factory TemplateEntry.text({
    required String name,
    required EntryType type,
    required String prompt,
    @Default(false) bool numeric,
    @Default(false) bool multiline,
    int? length,
    String? value,
    @Default(false) bool required,
  }) = TextEntry;

  factory TemplateEntry.checkbox({
    required String name,
    required EntryType type,
    required String prompt,
    @Default([]) List<String> excludes,
    @Default(false) bool value,
    @Default(false) bool required
  }) = CheckboxEntry;

  factory TemplateEntry.counter({
    required String name,
    required EntryType type,
    required String prompt,
    int? maxValue,
    int? value,
    @Default(false) bool required,
  }) = CounterEntry;

  factory TemplateEntry.picture({
    required String name,
    required EntryType type,
    required String prompt,
    @Default(false) bool required,
  }) = PictureEntry;

  factory TemplateEntry.fromJson(Map<String, Object?> json) =>
      _$TemplateEntryFromJson(json);
}

extension TemplateEntryList on List<TemplateEntry> {
  TemplateEntry? get(String name) {
    return firstWhereOrNull((e) => e.name == name);
  }
}
