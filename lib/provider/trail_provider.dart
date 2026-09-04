import 'dart:async';

import 'package:dio/dio.dart';
import 'package:forest_park_reports/model/snapped_latlng.dart';
import 'package:forest_park_reports/model/trail.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:forest_park_reports/provider/geojson_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:turf/turf.dart' as turf;

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
    final res = await (await ref.read(dioProvider.future)).get(
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

  // This function allows us to snap a location to the closest point on a route,
  // using the new backend's routes (routeProvider) rather than the legacy
  // /trail/all geometry. Each route is already a single named trail (the
  // Forest Park Conservancy source data has no OSM-relation-style segment
  // grouping to account for), so the resulting `trail` id is just the
  // route's own id.
  Future<SnappedResult> snapLocation(LatLng loc) async {
    final routes = await ref.read(routeProvider.future);
    final point = turf.Point(coordinates: turf.Position(loc.longitude, loc.latitude));

    turf.Feature<turf.Point>? closest;
    int? closestRouteId;
    for (final route in routes.features) {
      final geometry = route.geometry;
      if (geometry is! turf.LineString) continue;
      final routeId = int.tryParse(route.id.toString());
      if (routeId == null) continue;

      final candidate = turf.nearestPointOnLine(geometry, point, turf.Unit.meters);
      final candidateDist = candidate.properties!['dist'] as num;
      final closestDist = closest?.properties!['dist'] as num?;
      if (closest == null || candidateDist < closestDist!) {
        closest = candidate;
        closestRouteId = routeId;
      }
    }

    if (closest == null || closestRouteId == null) {
      throw StateError('No trail routes available to snap location to');
    }

    final coords = closest.geometry!.coordinates;
    final snappedLatLng = LatLng(coords.lat.toDouble(), coords.lng.toDouble());
    final index = closest.properties!['index'] as int;
    final dist = (closest.properties!['dist'] as num).toDouble();

    final snappedLoc = SnappedLatLng(closestRouteId, index, snappedLatLng);
    return SnappedResult(snappedLoc, dist);
  }
}
