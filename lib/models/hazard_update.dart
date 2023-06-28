import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hazard_update.g.dart';
part 'hazard_update.freezed.dart';

@freezed
class HazardUpdateModel with _$HazardUpdateModel {
  const HazardUpdateModel._();
  const factory HazardUpdateModel({
    required String uuid,
    required DateTime time,
    required String hazard,
    required bool active,
    String? image,
  }) = _HazardUpdateModel;

  factory HazardUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$HazardUpdateModelFromJson(json);

  String timeString() => kDisplayDateFormat.format(time.toLocal());
}

@freezed
class HazardUpdateRequestModel with _$HazardUpdateRequestModel {
  const HazardUpdateRequestModel._();
  const factory HazardUpdateRequestModel({
    required String hazard,
    required bool active,
    String? image,
  }) = _HazardUpdateRequestModel;

  factory HazardUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HazardUpdateRequestModelFromJson(json);
}