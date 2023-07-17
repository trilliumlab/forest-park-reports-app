import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'camera_position.freezed.dart';

@freezed
class CameraPosition with _$CameraPosition {
  const CameraPosition._();
  const factory CameraPosition({
    required LatLng center,
    required double zoom,
    @Default(0) double rotation,
  }) = _CameraPosition;
}
