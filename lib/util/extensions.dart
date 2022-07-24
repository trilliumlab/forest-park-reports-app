import 'dart:math';

import 'package:location/location.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

import 'length_unit.dart';

extension LocationDataLatLng on LocationData {
  LatLng? latLng() {
    return (latitude != null && longitude != null)
        ? LatLng(latitude!, longitude!)
        : null;
  }
}

extension RemoveTrailingZeros on double {
  String toStringRemoveTrailing(int fractionDigits) =>
      toStringAsFixed(fractionDigits).toString().replaceFirst(RegExp(r'\.?0*$'), '');
}

extension LatLngDistance on LatLng {
  double distanceFrom(LatLng other, [LengthUnit unit = LengthUnit.Meter]) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((other.latitude - latitude) * p)/2 +
        cos(latitude * p) * cos(other.latitude * p) *
            (1 - cos((other.longitude - longitude) * p))/2;
    return LengthUnit.Kilometer.to(unit, 12742 * asin(sqrt(a)));
  }
}
