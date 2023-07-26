import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// this stores whether camera follows the gps location. This will be set to
// false by panning the camera. when not stickied, pressing the sticky button
// will animate the camera to the current gps location and set sticky to true
final followOnLocationProvider = StateProvider<FollowOnLocationUpdate>(
        (ref) => FollowOnLocationUpdate.never
);