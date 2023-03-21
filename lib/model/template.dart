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

  TemplateTab? tab(ScoutingType type) {
    if (type == ScoutingType.pit) {
      return pit;
    } else if (type == ScoutingType.match) {
      return match;
    }
    return null;
  }

  ScoutingData newScoutingData(ScoutingType type) {
    return ScoutingData(
        uuid: uuidGen.v1(),
        templateUuid: uuid,
        templateVersion: version,
        type: type,
        created: DateTime.now(),
        updated: DateTime.now(),
        exported: false,
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
    @Default(false) bool exported,
    DateTime? storedAt,
    required List<TemplateEntry> data,
  }) = _ScoutingData;

  bool isSynced() {
    return storedAt == null ? false : storedAt!.isAfter(updated);
  }

  String displayName(String format) {
    return format.replaceAllMapped(RegExp(r'%(.*?)%'), (match) {
      final entry = data.get(match.group(1)!);
      if (entry != null && entry is TextEntry) {
        return entry.value ?? "";
      }
      return "";
    });
  }

  factory ScoutingData.fromJson(Map<String, dynamic> json) =>
      _$ScoutingDataFromJson(json);

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
