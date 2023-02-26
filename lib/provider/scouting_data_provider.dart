import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';

part 'scouting_data_provider.g.dart';

@riverpod
class ScoutingDataList extends _$ScoutingDataList {
  late final StoreRef<String, Map<String, dynamic>> store;
  @override
  Future<List<ScoutingData>> build(ScoutingType type) async {
    store = StoreRef(type.name);
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.find(db);
    return data.map((e) => ScoutingData.fromJson(e.value)).toList();
  }
  Future<void> put(ScoutingData data) async {
    final db = await ref.read(scoutingDatabaseProvider.future);
    await store.record(data.uuid).put(db, data.toJson());
    state = AsyncData([...((await future).where((e) => e.uuid != data.uuid)), data]);
  }
}
