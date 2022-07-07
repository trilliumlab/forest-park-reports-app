import 'package:latlong2/latlong.dart';

class NewHazardRequest {
  Hazard hazard;
  SnappedLatLng location;

  NewHazardRequest(this.hazard, this.location);

  Map<String, dynamic> toJson() {
    return {
      'hazard': hazard.value,
      'location': location.toJson(),
    };
  }
}

// A way of representing a LatLng pair that exists on a path. Stores
// the path uuid, along with the index of the point, and a LatLng pair
class SnappedLatLng extends LatLng {
  String trail;
  int index;

  SnappedLatLng(this.trail, this.index, LatLng loc) : super(loc.latitude, loc.longitude);

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
    return "${super.toString()} trailUuid:$trail, index:$index";
  }
}

enum Hazard {
  tree,
  flood,
  other
}
extension HazardValues on Hazard {
  String get value {
    switch (this) {
      case Hazard.tree:
        return "tree";
      case Hazard.flood:
        return "flood";
      case Hazard.other:
        return "other";
    }
  }
}
