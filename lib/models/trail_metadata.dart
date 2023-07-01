import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trail_metadata.g.dart';
part 'trail_metadata.freezed.dart';

@freezed
class TrailMetadataModel with _$TrailMetadataModel {
  const TrailMetadataModel._();
  const factory TrailMetadataModel({
    required String uuid,
    required String name,
  }) = _TrailMetadataModel;
  factory TrailMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$TrailMetadataModelFromJson(json);
}
