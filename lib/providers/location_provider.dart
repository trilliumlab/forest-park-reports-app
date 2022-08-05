import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:geolocator/geolocator.dart';

class LocationProviderNotifier extends StateNotifier<Position?> {
  final StateNotifierProviderRef ref;
  LocationProviderNotifier(this.ref) : super(null) {
    ref.watch(locationPermissionProvider);
    Geolocator.getPositionStream().listen((event) {
      state = event;
    });
  }

  Future<Position?> getLocation() async {
    final location = await Geolocator.getCurrentPosition();
    return state = location;
  }
}
final locationProvider = StateNotifierProvider<LocationProviderNotifier, Position?>((ref) {
  return LocationProviderNotifier(ref);
});

class LocationStatus {
  final LocationPermission permission;
  final LocationAccuracyStatus accuracy;
  LocationStatus([
    this.permission = LocationPermission.unableToDetermine,
    this.accuracy = LocationAccuracyStatus.unknown
  ]);
  @override
  String toString() => '{permission: $permission, accuracy: $accuracy}';
}

class LocationPermissionProviderNotifier extends StateNotifier<LocationStatus> {
  LocationPermissionProviderNotifier() : super(LocationStatus()) {
    checkPermission();
  }

  Future<LocationStatus> checkPermission({bool requestPrecise = false}) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.unableToDetermine 
        || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // get precise location
    var accuracy = await Geolocator.getLocationAccuracy();
    if (requestPrecise) {
      if (accuracy != LocationAccuracyStatus.precise) {
        if (Platform.isIOS && double.parse(Platform.operatingSystemVersion.split(" ")[1]) >= 14) {
          accuracy = await Geolocator.requestTemporaryFullAccuracy(purposeKey: 'hazard');
        } else {
          permission = await Geolocator.requestPermission();
          accuracy = await Geolocator.getLocationAccuracy();
        }
      }
    }
    state = LocationStatus(permission, accuracy);
    return state;
    // if (permission == PermissionStatus.notDetermined
    //     || (permission == PermissionStatus.restricted
    //         && (requestPrecise || permission != PermissionStatus.restricted)
    //         && !Platform.isIOS)
    //     || (permission == PermissionStatus.denied && !Platform.isIOS)
    // ) {
    //   state = await requestPermission();
    // } else {
    //   state = permission;
    // }
  }
}
final locationPermissionProvider = StateNotifierProvider<LocationPermissionProviderNotifier, LocationStatus>((ref) {
  return LocationPermissionProviderNotifier();
});
