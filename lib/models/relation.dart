import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'relation.g.dart';
part 'relation.freezed.dart';

extension RelationList on List<RelationModel> {
  RelationModel? get(int id) {
    return firstWhereOrNull((relation) => relation.id == id);
  }
  RelationModel? forTrail(int id) {
    return firstWhereOrNull((relation) => relation.members.contains(id));
  }
}

@freezed
class RelationModel with _$RelationModel {
  const RelationModel._();
  const factory RelationModel({
    required int id,
    required Map<String, String> tags,
    required List<int> members
  }) = _RelationModel;

  factory RelationModel.fromJson(Map<String, dynamic> json) =>
      _$RelationModelFromJson(json);
}
