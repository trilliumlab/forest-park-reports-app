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

  Future checkPermission() async {
    var status = await getPermissionStatus();
    if (!status.authorized) {
      state = await requestPermission();
    }
  }

  _showMissingPermissionDialog(BuildContext context, String message) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Missing Location Permissions'),
        content: Text(message),
      ),
    );
  }

  Future<PermissionStatus> requirePermission(BuildContext context) async {
    await checkPermission();
    if (state == PermissionStatus.denied) {
      _showMissingPermissionDialog(context, 'Need location permission');
    }
    if (state == PermissionStatus.restricted) {
      _showMissingPermissionDialog(context, 'Need precise location permission');
    }
    return state!;
  }
}
final locationPermissionProvider = StateNotifierProvider<LocationPermissionProviderNotifier, PermissionStatus?>((ref) {
  return LocationPermissionProviderNotifier();
});
