import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

extension LocationDataLatLng on LocationData {
  LatLng? latLng() {
    return (latitude != null && longitude != null)
        ? LatLng(latitude!, longitude!)
        : null;
  }
}