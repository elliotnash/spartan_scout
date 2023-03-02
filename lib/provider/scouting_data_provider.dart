import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';
import 'package:spartan_scout/provider/dio_provider.dart';

part 'scouting_data_provider.g.dart';

@riverpod
class ScoutingDataList extends _$ScoutingDataList {
  late final StoreRef<String, Map<String, dynamic>> store;
  @override
  Future<List<ScoutingData>> build(ScoutingType type) async {
    store = StoreRef(type.name);
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.find(db);
    load();
    return data.map((e) => ScoutingData.fromJson(e.value)).toList();
  }
  Future<void> load() async {
    final res = await ref.read(scoutingDioProvider).get("$kBaseUrl/${type.name}");
    List<dynamic> data = res.data;
    state = AsyncData([
      for (final Map<String, dynamic> entry in data)
        await ScoutingData.fromSimpleJson(entry, ref)
    ]);
    // state = AsyncData((await Future.wait(res.data.map((e) => ScoutingData.fromSimpleJson(e, ref)))).toList());
  }
  Future<void> put(ScoutingData data) async {
    ref.read(scoutingDioProvider).post(
        "$kBaseUrl/${type.name}",
        data: data.toJsonSimple()
    ).then((res) async {
      state = AsyncData([
        ...((await future).where((e) => e.uuid != data.uuid)),
        await ScoutingData.fromSimpleJson(res.data, ref)
      ]);
    });

    final db = await ref.read(scoutingDatabaseProvider.future);
    await store.record(data.uuid).put(db, data.toJson());
    state = AsyncData([...((await future).where((e) => e.uuid != data.uuid)), data]);
  }
}
