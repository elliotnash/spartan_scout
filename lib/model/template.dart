import 'package:freezed_annotation/freezed_annotation.dart';

part 'template.freezed.dart';
part 'template.g.dart';

@freezed
class Template with _$Template {
  const factory Template({
    required String name,
    required List<TemplateEntry> pit
  }) = _Template;

  factory Template.fromJson(Map<String, Object?> json)
      => _$TemplateFromJson(json);
}

enum EntryType {
  text,
  numeric,
}

@freezed
class TemplateEntry with _$TemplateEntry {
  const factory TemplateEntry({
    required String name,
    required EntryType type,
    required String prompt,
  }) = _TemplateEntry;

  factory TemplateEntry.fromJson(Map<String, Object?> json)
      => _$TemplateEntryFromJson(json);
}
