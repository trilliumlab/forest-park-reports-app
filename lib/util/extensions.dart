import 'dart:math';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

extension LocationDataLatLng on Position {
  LatLng? latLng() =>
      LatLng(latitude, longitude);
}

extension LatLngBearing on LatLng {
  double bearingTo(LatLng other) {
    final y = sin(other.longitudeInRad - longitudeInRad) *
        cos(other.latitudeInRad);
    final x = cos(latitudeInRad) * sin(other.latitudeInRad) -
        sin(latitudeInRad) *
            cos(other.latitudeInRad) *
            cos(other.longitudeInRad - longitudeInRad);

    return atan2(y, x);
  }
}

extension Authorized on LocationPermission {
  bool get authorized =>
      this == LocationPermission.always
          || this == LocationPermission.whileInUse;
}

extension RemoveTrailingZeros on double {
  String toStringRemoveTrailing(int fractionDigits) =>
      toStringAsFixed(fractionDigits).toString().replaceFirst(RegExp(r'\.?0*$'), '');
}

extension PositionToMarker on Position {
  LocationMarkerPosition locationMarkerPosition() =>
      LocationMarkerPosition(latitude: latitude, longitude: longitude, accuracy: accuracy);
  LocationMarkerHeading locationMarkerHeading() =>
      LocationMarkerHeading(heading: heading, accuracy: accuracy);
}
