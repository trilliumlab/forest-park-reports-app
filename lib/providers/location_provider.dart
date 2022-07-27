import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

class LocationProviderNotifier extends StateNotifier<LocationData?> {
  LocationProviderNotifier() : super(null) {
    onLocationChanged().listen((event) {
      state = event;
    });
  }

  Future<LocationData?> getLocation() async {
    final location = await getLocation();
    if (location != null) {
      state = location;
    }
    return location;
  }
}

final locationProvider = StateNotifierProvider<LocationProviderNotifier, LocationData?>((ref) {
  return LocationProviderNotifier();
});
