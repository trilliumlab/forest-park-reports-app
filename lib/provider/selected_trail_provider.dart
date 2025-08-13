import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:turf/turf.dart';

part 'selected_trail_provider.g.dart'; // This must match the file name exactly

@Riverpod(keepAlive: true)
class SelectedTrail extends _$SelectedTrail {
  @override
  Feature? build() => null;

  void select(Feature trail) {
    state = trail;
  }

  void clear() {
    state = null;
  }
}
