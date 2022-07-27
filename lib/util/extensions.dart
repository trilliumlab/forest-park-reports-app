import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

extension LocationDataLatLng on LocationData {
  LatLng? latLng() {
    return (latitude != null && longitude != null)
        ? LatLng(latitude!, longitude!)
        : null;
  }
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

extension RemoveTrailingZeros on double {
  String toStringRemoveTrailing(int fractionDigits) =>
      toStringAsFixed(fractionDigits).toString().replaceFirst(RegExp(r'\.?0*$'), '');
}
