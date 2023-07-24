import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'snapped_latlng.freezed.dart';

// A way of representing a LatLng pair that exists on a path. Stores
// the path uuid, along with the index of the point, and a LatLng pair
class SnappedLatLng extends LatLng {
  int trail;
  int node;

  SnappedLatLng(this.trail, this.node, LatLng loc) : super(loc.latitude, loc.longitude);

  SnappedLatLng.fromJson(Map<String, dynamic> json)
      : trail = json['trail'],
        node = json['node'],
        super(json['lat'], json['long']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'trail': trail,
      'node': node,
      'lat': latitude,
      'long': longitude,
    };
  }
  @override
  String toString() {
    return "[${super.toString()} trailID:$trail, node:$node]";
  }
}

@freezed
class SnappedResult with _$SnappedResult {
  const SnappedResult._();
  const factory SnappedResult(SnappedLatLng location, double distance) = _SnappedResult;
}
