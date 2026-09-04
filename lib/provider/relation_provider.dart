import 'package:forest_park_reports/model/relation.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'relation_provider.g.dart';

@riverpod
class Relations extends _$Relations {
  @override
  Future<List<RelationModel>> build() async {
    final db = ref.watch(databaseProvider);

    final relations = await db.select(db.relationsTable).get();

    if (relations.isNotEmpty) {
      refresh();
      return relations;
    }
    return await _fetch();
  }

  Future<List<RelationModel>> _fetch() async {
    final res = await (await ref.read(dioProvider.future)).get("/trail/relations",);

    final relations = [
      for (final relation in res.data)
        RelationModel.fromJson(relation)
    ];

    final db = ref.read(databaseProvider);
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.relationsTable, relations);
    });

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
