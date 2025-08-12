import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_trail_provider.g.dart'; // This must match the file name exactly

@Riverpod(keepAlive: true)
class SelectedTrail extends _$SelectedTrail {
  @override
  Map<String, dynamic>? build() => null;

  void select(Map<String, dynamic> trail) {
    state = trail;
  }

  void clear() {
    state = null;
  }
}
