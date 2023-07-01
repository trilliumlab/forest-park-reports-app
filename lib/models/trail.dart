import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/models/track.dart';
import 'package:forest_park_reports/models/trail_metadata.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trail.freezed.dart';

@freezed
class TrailModel with _$TrailModel {
  const TrailModel._();
  const factory TrailModel({
    required TrailMetadataModel metadata,
    required TrackModel track,
  }) = _TrailModel;
}
