import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:gpx/gpx.dart';
import 'package:uuid/uuid.dart';

class Api {
  static String baseUrl = "http://192.168.1.100:3000/api/v1/";
  static BaseOptions options = BaseOptions(
    baseUrl: baseUrl
  );
  static GpxReader gpxReader = GpxReader();
  Dio dio = Dio(options);
  Future<Map<String, Trail>> getTrails() async {
    final res = await dio.get("/trails/list");
    return {
      for (final val in res.data.values)
        val["uuid"]: Trail(val["name"], val["uuid"])
    };
  }
  Future<Track> getTrack(String uuid) async {
    final res = await dio.get("/trails/$uuid");
    return Track(gpxReader.fromString(res.data));
  }
}

final apiProvider = Provider<Api>((ref) => Api());

// A provider that will load all the trail data from the server
// and can be refreshed to fetch new data.
class RemoteTrailsNotifier extends StateNotifier<Map<String, Trail>> {
  StateNotifierProviderRef ref;
  late Api api;
  RemoteTrailsNotifier(this.ref) : super({}) {
    api = ref.watch(apiProvider);
    fetchTrails();
  }
  Future fetchTrails() async {
    state = await api.getTrails();
    for (final trail in state.values) {
      final track = await api.getTrack(trail.uuid);
      state = {
        for (final oldTrail in state.values)
          if (oldTrail.uuid == trail.uuid)
            oldTrail.uuid: oldTrail.copyWith(track: track)
          else
            oldTrail.uuid: oldTrail
      };
    }
  }
}

final remoteTrailsProvider = StateNotifierProvider<RemoteTrailsNotifier, Map<String, Trail>>((ref) {
  return RemoteTrailsNotifier(ref);
});
