import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';
import 'package:spartan_scout/provider/dio_provider.dart';
import 'package:spartan_scout/provider/flushbar_provider.dart';

part 'scouting_data_provider.g.dart';

@riverpod
class ScoutingDataList extends _$ScoutingDataList {
  late final StoreRef<String, Map<String, dynamic>> store;
  @override
  Future<List<ScoutingData>> build(ScoutingType type) async {
    print("calling build");
    store = StoreRef(type.name);
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.find(db);
    load();
    return data.map((e) => ScoutingData.fromJson(e.value)).toList();
  }
  Future<void> load() async {
    try {
      final res = await ref.read(scoutingDioProvider).get(
          "$kBaseUrl/${type.name}");
      List<dynamic> data = res.data;
      state = AsyncData([
        for (final Map<String, dynamic> entry in data)
          await _loadAndSave(await ScoutingData.fromSimpleJson(entry, ref))
      ]);
    } catch (e) {
      String message = e.toString();
      if (e is DioError) {
        final error = e.error;
        if (error is SocketException) {
          if (error.osError!.errorCode == 61) {
            message = "Failed to connect to server!";
          }
        }
      }
      ref.read(flushbarMessageProvider.notifier).set(message);
    }
    // state = AsyncData((await Future.wait(res.data.map((e) => ScoutingData.fromSimpleJson(e, ref)))).toList());
  }
  Future<ScoutingData> _loadAndSave(ScoutingData data) async {
    final db = await ref.read(scoutingDatabaseProvider.future);
    await store.record(data.uuid).put(db, data.toJson());
    return data;
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
