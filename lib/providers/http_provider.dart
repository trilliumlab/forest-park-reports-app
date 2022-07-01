import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:uuid/uuid.dart';

class Api {
  static String baseUrl = "http://192.168.1.169:3000/api/v1/";
  static BaseOptions options = BaseOptions(
    baseUrl: baseUrl
  );
  Dio dio = Dio(options);
  Future<Map<String, Trail>> getTrails() async {
    final res = await dio.get("/trails/list");
    return {
      for (final val in res.data.values)
        val["uuid"]: Trail(val["name"], val["uuid"])
    };
  }
}

final apiProvider = Provider<Api>((ref) => Api());

// A provider that can be watched and will update once all the trails are
// loaded can also be refreshed to reload the trail map from disk
// see https://riverpod.dev/docs/providers/future_provider/
// final rawTrailsProvider = FutureProvider<Map<String, Trail>>((ref) async {
//   // get file path of all gpx files in asset folder
//   final manifestContent = await rootB.loadString('AssetManifest.json');
//   final List<String> pathPaths = json.decode(manifestContent).keys
//       .where((String key) => key.startsWith("assets/trails"))
//       .where((String key) => key.contains('.gpx')).toList();
//
//   // load the gpx files and create a map of trails with the trail name
//   // TODO this should be a uuid
//   final Map<String, Trail> trails = {};
//   for (var path in pathPaths) {
//     path = Uri.decodeFull(path);
//     var name = path.split("/")[2];
//     trails[name] = (Trail(
//         name, GpxReader().fromString(await rootBundle.loadString(path))
//     ));
//   }
//
//   return trails;
// });

class RawTrailsNotifier extends StateNotifier<Map<String, Trail>> {
  StateNotifierProviderRef ref;
  late Api api;
  RawTrailsNotifier(this.ref) : super({}) {
    api = ref.watch(apiProvider);
    _fetchList();
  }
  Future _fetchList() async {
    state = await api.getTrails();
    for (final trail in state.values) {

    }
  }
}

final rawTrailsProvider = StateNotifierProvider<RawTrailsNotifier, Map<String, Trail>>((ref) {
  return RawTrailsNotifier(ref);
});
