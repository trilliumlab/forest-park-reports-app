import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'snapped_latlng.freezed.dart';

// A way of representing a LatLng pair that exists on a path. Stores
// the path uuid, along with the index of the point, and a LatLng pair
class SnappedLatLng extends LatLng {
  String trail;
  int index;

  SnappedLatLng(this.trail, this.index, LatLng loc) : super(loc.latitude, loc.longitude);

  SnappedLatLng.fromJson(Map<String, dynamic> json)
      : trail = json['trail'],
        index = json['index'],
        super(json['lat'], json['long']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'trail': trail,
      'index': index,
      'lat': latitude,
      'long': longitude,
    };
  }
  @override
  String toString() {
    return "[${super.toString()} trailUuid:$trail, index:$index]";
  }
}

@freezed
class SnappedResult with _$SnappedResult {
  const SnappedResult._();
  const factory SnappedResult(SnappedLatLng location, double distance) = _SnappedResult;
}
