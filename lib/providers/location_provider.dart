import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

@riverpod
Stream<Position> location(LocationRef ref) {
  ref.watch(locationPermissionStatusProvider);
  return Geolocator.getPositionStream();
}

// class LocationProviderNotifier extends StateNotifier<Position?> {
//   final StateNotifierProviderRef ref;
//   LocationProviderNotifier(this.ref) : super(null) {
//     ref.watch(locationPermissionProvider);
//     Geolocator.getPositionStream().listen((event) {
//       print("GOT NEW LOCATION");
//       state = event;
//     });
//   }
//
//   Future<Position?> getLocation() async {
//     final location = await Geolocator.getCurrentPosition();
//     return state = location;
//   }
// }
// final locationProvider = StateNotifierProvider<LocationProviderNotifier, Position?>((ref) {
//   return LocationProviderNotifier(ref);
// });

class LocationPermissionStatusState {
  final LocationPermission permission;
  final LocationAccuracyStatus accuracy;
  LocationPermissionStatusState([
    this.permission = LocationPermission.unableToDetermine,
    this.accuracy = LocationAccuracyStatus.unknown
  ]);
  @override
  String toString() => '{permission: $permission, accuracy: $accuracy}';
}

@riverpod
class LocationPermissionStatus extends _$LocationPermissionStatus {
  @override
  LocationPermissionStatusState build() {
    checkPermission();
    return LocationPermissionStatusState();
  }

  Future<LocationPermissionStatusState> checkPermission({bool requestPrecise = false}) async {
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
    state = LocationPermissionStatusState(permission, accuracy);
    return state;
    //TODO look at this
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

// class LocationPermissionProviderNotifier extends StateNotifier<LocationPermissionStatusState> {
//   LocationPermissionProviderNotifier() : super(LocationPermissionStatusState()) {
//     checkPermission();
//   }
//
//   Future<LocationPermissionStatusState> checkPermission({bool requestPrecise = false}) async {
//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.unableToDetermine
//         || permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     // get precise location
//     var accuracy = await Geolocator.getLocationAccuracy();
//     if (requestPrecise) {
//       if (accuracy != LocationAccuracyStatus.precise) {
//         if (Platform.isIOS && double.parse(Platform.operatingSystemVersion.split(" ")[1]) >= 14) {
//           accuracy = await Geolocator.requestTemporaryFullAccuracy(purposeKey: 'hazard');
//         } else {
//           permission = await Geolocator.requestPermission();
//           accuracy = await Geolocator.getLocationAccuracy();
//         }
//       }
//     }
//     state = LocationPermissionStatusState(permission, accuracy);
//     return state;
//     // if (permission == PermissionStatus.notDetermined
//     //     || (permission == PermissionStatus.restricted
//     //         && (requestPrecise || permission != PermissionStatus.restricted)
//     //         && !Platform.isIOS)
//     //     || (permission == PermissionStatus.denied && !Platform.isIOS)
//     // ) {
//     //   state = await requestPermission();
//     // } else {
//     //   state = permission;
//     // }
//   }
// }
// final locationPermissionStatusProvider = StateNotifierProvider<LocationPermissionProviderNotifier, LocationPermissionStatusState>((ref) {
//   return LocationPermissionProviderNotifier();
// });
