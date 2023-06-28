import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/models/hazard_type.dart';
import 'package:forest_park_reports/models/snapped_latlng.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hazard.g.dart';
part 'hazard.freezed.dart';

@freezed
class HazardModel with _$HazardModel {
  const HazardModel._();
  const factory HazardModel({
    required String uuid,
    required DateTime time,
    required HazardType hazard,
    required SnappedLatLng location,
    required String? image,
  }) = _HazardModel;

  factory HazardModel.fromJson(Map<String, dynamic> json) =>
      _$HazardModelFromJson(json);

  String timeString() => kDisplayDateFormat.format(time.toLocal());
}

@freezed
class HazardRequestModel with _$HazardRequestModel {
  const HazardRequestModel._();
  const factory HazardRequestModel({
    required HazardType hazard,
    required SnappedLatLng location,
    required String? image,
  }) = _HazardRequestModel;

  factory HazardRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HazardRequestModelFromJson(json);
}
