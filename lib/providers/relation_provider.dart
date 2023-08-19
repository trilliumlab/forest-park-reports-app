import 'package:dio/dio.dart';
import 'package:forest_park_reports/models/relation.dart';
import 'package:forest_park_reports/providers/database_provider.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';

part 'relation_provider.g.dart';

@riverpod
class Relations extends _$Relations {
  static final store = StoreRef<int, Map<String, dynamic>>("relations");

  @override
  Future<List<RelationModel>> build() async {
    final db = await ref.watch(forestParkDatabaseProvider.future);

    final relations = [
      for (final relation in await store.find(db))
        RelationModel.fromJson(relation.value)
    ];

    if (relations.isNotEmpty) {
      refresh();
      return relations;
    }
    return await _fetch();
  }

  Future<List<RelationModel>> _fetch() async {
    final res = await ref.read(dioProvider).get("/trail/relations",);

    final relations = [
      for (final relation in res.data)
        RelationModel.fromJson(relation)
    ];

    final db = await ref.read(forestParkDatabaseProvider.future);
    for (final relation in relations) {
      store.record(relation.id).add(db, relation.toJson());
    }

    return relations;
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }
}

@riverpod
class SelectedRelation extends _$SelectedRelation {
  @override
  int? build() => null;

  void deselect() => state = null;
  void select(int? selection) => state = selection;
}
