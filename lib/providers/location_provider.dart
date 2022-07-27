import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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

class LocationPermissionProviderNotifier extends StateNotifier<PermissionStatus?> {
  LocationPermissionProviderNotifier() : super(null) {
    checkPermission();
  }

  Future<PermissionStatus> checkPermission({bool requestPrecise = true}) async {
    var status = await getPermissionStatus();
    if (!Platform.isIOS && !status.authorized && (requestPrecise || status != PermissionStatus.restricted)) {
      state = await requestPermission();
    } else {
      state = status;
    }
    return state!;
  }
}
final locationPermissionProvider = StateNotifierProvider<LocationPermissionProviderNotifier, PermissionStatus?>((ref) {
  return LocationPermissionProviderNotifier();
});
