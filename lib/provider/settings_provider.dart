import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:spartan_scout/provider/database_provider.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  late final StoreRef<String, dynamic> store;
  @override
  Future<Map<String, dynamic>> build() async {
    store = StoreRef("settings");
    final db = await ref.read(scoutingDatabaseProvider.future);
    final data = await store.find(db);
    return {
      for (final entry in data)
        entry.key: entry.value
    };
  }
  Future<void> put(String key, dynamic value) async {
    state = await AsyncValue.guard(() async {
      final db = await ref.read(scoutingDatabaseProvider.future);
      await store.record(key).put(db, value);
      final data = await future;
      data[key] = value;
      return {...data};
    });
  }
}
