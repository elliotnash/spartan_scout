import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'template.freezed.dart';
part 'template.g.dart';

const uuidGen = Uuid();

@Freezed(makeCollectionsUnmodifiable: false)
class Template with _$Template {
  const Template._();
  const factory Template({
    required String name,
    required String vid,
    required List<TemplateEntry> pit,
    required List<TemplateEntry> match,
  }) = _Template;

  ScoutingData newScoutingData(ScoutingType type) {
    return ScoutingData(
        uuid: uuidGen.v1(),
        templateVid: vid,
        type: type,
        created: DateTime.now(),
        updated: DateTime.now(),
        data: [
          for (final entry in type == ScoutingType.pit ? pit : match)
            entry.copyWith()
        ]);
  }

  factory Template.fromJson(Map<String, Object?> json) =>
      _$TemplateFromJson(json);
}

enum ScoutingType { pit, match }

@Freezed(
  addImplicitFinal: false,
  makeCollectionsUnmodifiable: false,
)
class ScoutingData with _$ScoutingData {
  const ScoutingData._();
  factory ScoutingData({
    required String uuid,
    required String templateVid,
    required ScoutingType type,
    required DateTime created,
    required DateTime updated,
    required List<TemplateEntry> data,
  }) = _ScoutingData;

  factory ScoutingData.fromJson(Map<String, dynamic> json) =>
      _$ScoutingDataFromJson(json);

  Map<String, Object?> toJsonSimple() {
    return {
      "uuid": uuid,
      "templateVid": templateVid,
      "type": type.name,
      "created": created,
      "updated": updated,
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
