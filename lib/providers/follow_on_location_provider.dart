import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../consts.dart';

part 'follow_on_location_provider.g.dart';

enum FollowOnLocationTargetState {
  none(FollowOnLocationUpdate.never),
  currentLocation(FollowOnLocationUpdate.always),
  forestPark(FollowOnLocationUpdate.never);

  final FollowOnLocationUpdate update;
  const FollowOnLocationTargetState(this.update);
}


@riverpod
class FollowOnLocationTarget extends _$FollowOnLocationTarget {
  @override
  FollowOnLocationTargetState build() => FollowOnLocationTargetState.none;
  void update(FollowOnLocationTargetState followOnLocationTargetState) {
    state = followOnLocationTargetState;
  }
}