import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

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
