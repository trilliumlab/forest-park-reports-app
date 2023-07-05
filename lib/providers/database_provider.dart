import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

part 'database_provider.g.dart';

@riverpod
class ForestParkDatabase extends _$ForestParkDatabase {
  @override
  Future<Database> build() async {
    if (kIsWeb) {
      return databaseFactoryWeb.openDatabase(kDbName);
    } else {
      return await databaseFactoryIo.openDatabase(await ref.watch(dbPathProvider.future));
    }
  }

  Future<void> delete() async {
    if (kIsWeb) {
      databaseFactoryWeb.deleteDatabase(kDbName);
    } else {
      await File(await ref.read(dbPathProvider.future)).delete();
    }
  }
}

@riverpod
Future<String> dbPath(DbPathRef ref) async {
  if (kIsWeb) {
    return "";
  }
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return join(dir.path, "$kDbName.db");
}
