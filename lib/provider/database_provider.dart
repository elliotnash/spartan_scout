import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

part 'database_provider.g.dart';

@riverpod
class ScoutingDatabase extends _$ScoutingDatabase {
  static const _dbName = 'scouting';
  Future<String> _getDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return join(dir.path, "$_dbName.db");
  }

  @override
  Future<Database> build() async {
    if (kIsWeb) {
      return databaseFactoryWeb.openDatabase(_dbName);
    } else {
      return await databaseFactoryIo.openDatabase(await _getDbPath());
    }
  }

  Future<void> delete() async {
    if (kIsWeb) {
      // TODO
    } else {
      await File(await _getDbPath()).delete();
    }
  }
}
