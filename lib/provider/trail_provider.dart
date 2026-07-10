import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:forest_park_reports/model/snapped_latlng.dart';
import 'package:forest_park_reports/model/trail.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:forest_park_reports/provider/geojson_provider.dart';

part 'trail_provider.g.dart';

@Riverpod(keepAlive: true)
class Trails extends _$Trails {
  @override
  Future<TrailList> build() async {
    final db = ref.watch(databaseProvider);
    final trails = TrailList(await db.select(db.trailsTable).get());

    if (trails.isNotEmpty) {
      refresh();
      return trails;
    }
    return await _fetch();
  }

  Future<TrailList> _fetch() async {
    final res = await ref.read(dioProvider).get(
      "/trail/all",
      options: Options(
          responseType: ResponseType.bytes
      ),
    );

    final trails = TrailList.decode(res.data);

    final db = ref.read(databaseProvider);
    await db.delete(db.trailsTable).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.trailsTable, trails);
    });

    return trails;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  // TODO we might need higher resolution here than the closest point
  // This function allows us to snap a location to the closest point on a path.
  Future<SnappedResult> snapLocation(LatLng loc) async {

    final routes = await ref.read(routeProvider.future);

    double? squareDist;
    int? closestTrail;
    LatLng? closestLatLng;
    int index = 0;

    for (final route in routes.features) {
      final routeJson = route.toJson();
      final routeId = int.tryParse(route.id.toString()) ?? 0;
      final coordinates =
          routeJson['geometry']['coordinates'] as List<dynamic>;

      for (int i = 0; i < coordinates.length; i++) {
        final coord = coordinates[i] as List<dynamic>;
        final latLng = LatLng(
          (coord[1] as num).toDouble(),
          (coord[0] as num).toDouble(),
        );

        final dist = _squareDist(loc, latLng);
        if (squareDist == null || dist < squareDist) {
          squareDist = dist;
          closestTrail = routeId;
          closestLatLng = latLng;
          index = i;
        }
      }
    }

      /* old version of the one up above
    final trailList = await future;

    // this technically won't get an accurate distance as as much
    // as i'd like the earth to be flat, it's not. However, this
    // should be good enough to sort by distance, and it's fast.
    double? squareDist;
    int? closestTrail;
    LatLng? closestLatLng;
    int index = 0;
    for (final trail in trailList) {
      final geometry = trail.geometry;
      for (int i=0; i<geometry.length; i++) {
        final dist = _squareDist(loc, geometry[i]);
        if (squareDist == null || dist < squareDist) {
          squareDist = dist;
          closestTrail = trail.id;
          closestLatLng = geometry[i];
          index = i;
        }
      }
    }
*/
    final snappedLoc = SnappedLatLng(closestTrail!, index, closestLatLng!);
    final dist = const DistanceVincenty().as(LengthUnit.Meter, loc, snappedLoc);
    return SnappedResult(snappedLoc, dist);
  }
  double _squareDist(LatLng p1, LatLng p2) {
    return pow(p1.latitude-p2.latitude, 2) + pow(p1.longitude-p2.longitude, 2) as double;
  }
}
