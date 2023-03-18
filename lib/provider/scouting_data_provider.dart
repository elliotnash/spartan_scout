import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';
import 'package:spartan_scout/provider/dio_provider.dart';
import 'package:spartan_scout/widgets/snackbar.dart';

part 'scouting_data_provider.g.dart';

@riverpod
class ScoutingDataList extends _$ScoutingDataList {
  late StoreRef<String, Map<String, dynamic>> store;
  
  Timer? timer;

  @override
  Future<List<ScoutingData>> build(ScoutingType type) async {
    store = StoreRef(type.name);
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.find(db);
    load().then((value) => _postMissing());
    timer = Timer.periodic(kRetryInterval, (timer) => _postMissing());
    return data.map((e) => ScoutingData.fromJson(e.value)).toList();
  }

  Future<void> load({bool alertError = true}) async {
    try {
      final res = await ref.read(scoutingDioProvider).get(
          "$kBaseUrl/${type.name}");
      List<dynamic> data = res.data;
      state = AsyncData([
        for (final entry in await future)
          if (!entry.isSynced())
            entry,
        for (final Map<String, dynamic> entry in data)
          await _save(await ScoutingData.fromSimpleJson(entry, ref)),
      ]);
      final db = await ref.read(scoutingDatabaseProvider.future);
      for (final record in await store.find(db)) {
        final entry = ScoutingData.fromJson(record.value);
        if (!state.value!.contains(entry)) {
          await store.record(entry.uuid).delete(db);
        }
      }
    } catch (e) {
      _onError(e, alertError);
    }
    // state = AsyncData((await Future.wait(res.data.map((e) => ScoutingData.fromSimpleJson(e, ref)))).toList());
  }

  Future<ScoutingData> _save(ScoutingData data) async {
    final db = await ref.read(scoutingDatabaseProvider.future);
    await store.record(data.uuid).put(db, data.toJson());
    return data;
  }

  Future<void> _postMissing() async {
    for (final data in await future) {
      if (!data.isSynced()) {
        _post(data, alertError: false);
      }
    }
  }

  void _onError(Object e, bool alert) {
    String message = e.toString();
    if (e is DioError) {
      final error = e.error;
      if (error is SocketException) {
        if (error.osError!.errorCode == 61) {
          message = "Failed to connect to server!";
        }
      }
    }
    if (alert) {
      showSnackbar(Text(message));
    }
    print(type);
    print(e);
  }

  Future<void> _post(ScoutingData data, {bool alertError = true}) async {
    try {
      final res = await ref.read(scoutingDioProvider).post(
          "$kBaseUrl/${type.name}",
          data: data.toJsonSimple()
      );
      final newData = await ScoutingData.fromSimpleJson(res.data, ref);
      state = AsyncData([
        ...((await future).where((e) => e.uuid != data.uuid)),
        newData,
      ]);
      _save(newData);
    } catch (e) {
      _onError(e, alertError);
    }
  }

  Future<void> put(ScoutingData data) async {
    await _save(data);
    state = AsyncData([...((await future).where((e) => e.uuid != data.uuid)), data]);
    _post(data);
  }

  Future<bool> delete(String uuid) async {
    try {
      final res = await ref.read(scoutingDioProvider).delete(
          "$kBaseUrl/${type.name}",
          data: jsonEncode({"uuid": uuid}),
      );
      state = AsyncData([...((await future).where((e) => e.uuid != uuid))]);

      final db = await ref.read(scoutingDatabaseProvider.future);
      await store.record(uuid).delete(db);
      return true;
    } catch (e) {
      _onError(e, true);
    }
    return false;
  }
}
