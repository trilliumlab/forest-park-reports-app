import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:forest_park_reports/models/snapped_latlng.dart';
import 'package:forest_park_reports/models/trail.dart';
import 'package:forest_park_reports/providers/database_provider.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/blob.dart';
import 'package:sembast/sembast.dart';

part 'trail_provider.g.dart';

@riverpod
class PolylineResolution extends _$PolylineResolution {
  @override
  PolylineResolutionModel build() => PolylineResolutionModel.low;

  void updateZoom(double zoom) {
    state = PolylineResolutionModel.resolutionFromZoom(zoom);
  }
}

@riverpod
class TrailList extends _$TrailList {
  static final store = StoreRef<String, int>("trail_list");

  @override
  Future<Set<int>> build() async {
    final db = await ref.watch(forestParkDatabaseProvider.future);
    final trails = (await store.find(db)).map((e) => e.value).toSet();
    if (trails.isNotEmpty) {
      refresh();
      return trails;
    }
    return await _fetch();
  }

  Future<Set<int>> _fetch() async {
    final res = await ref.read(dioProvider).get("/trail/list");

    final List<int> trails = [
      for (final trailID in res.data)
        trailID
    ];

    final db = await ref.read(forestParkDatabaseProvider.future);
    db.transaction((txn) {
      store.delete(db);
      store.addAll(db, trails);
    });

    return trails.toSet();
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }

  // TODO we might need higher resolution here than the closest point
  // This function allows us to snap a location to the closest point on a path.
  Future<SnappedResult> snapLocation(LatLng loc) async {
    final trailList = await future;

    // this technically won't get an accurate distance as as much
    // as i'd like the earth to be flat, it's not. However, this
    // should be good enough to sort by distance, and it's fast.
    double? squareDist;
    int? closestTrail;
    LatLng? closestLatLng;
    int index = 0;
    await Future.wait(trailList.map((trailID) async {
      final trail = await ref.read(trailProvider(trailID).future);
      final geometry = trail.geometry;
      for (int i=0; i<geometry.length; i++) {
        final dist = _squareDist(loc, geometry[i]);
        if (squareDist == null || dist < squareDist!) {
          squareDist = dist;
          closestTrail = trailID;
          closestLatLng = geometry[i];
          index = i;
        }
      }
    }));

    final snappedLoc = SnappedLatLng(closestTrail!, index, closestLatLng!);
    final dist = const DistanceVincenty().as(LengthUnit.Meter, loc, snappedLoc);
    return SnappedResult(snappedLoc, dist);
  }
  double _squareDist(LatLng p1, LatLng p2) {
    return pow(p1.latitude-p2.latitude, 2) + pow(p1.longitude-p2.longitude, 2) as double;
  }
}

@riverpod
class Trail extends _$Trail {
  static final store = StoreRef<int, Blob>("trail_data");

  @override
  Future<TrailModel> build(int id) async {
    final db = await ref.watch(forestParkDatabaseProvider.future);
    final trailBlob = await store.record(id).get(db);
    if (trailBlob == null) {
      return await _fetch();
    }
    refresh();
    return TrailModel.decode(trailBlob.bytes);
  }

  Future<TrailModel> _fetch() async {
    final res = await ref.read(dioProvider).get(
      "/trail/$id",
      options: Options(
          responseType: ResponseType.bytes
      ),
    );

    final db = await ref.read(forestParkDatabaseProvider.future);
    store.record(id).add(db, Blob(res.data));

    return TrailModel.decode(res.data);
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }
}

@riverpod
class SelectedTrail extends _$SelectedTrail {
  @override
  int? build() => null;

  void deselect() => state = null;
  void select(int? selection) => state = selection;
}
