import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_cursor_provider.g.dart';

@riverpod
class MapCursor extends _$MapCursor {
  @override
  LatLng? build() => null;

  void set(LatLng? position) =>
    state = position;

  void clear() =>
    state = null;
}
