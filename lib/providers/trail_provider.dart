import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:forest_park_reports/models/snapped_latlng.dart';
import 'package:forest_park_reports/models/trail.dart';
import 'package:forest_park_reports/models/trail_metadata.dart';
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
  static final store = intMapStoreFactory.store("trail_metadata");

  @override
  Future<Set<TrailMetadataModel>> build() async {
    final db = await ref.watch(forestParkDatabaseProvider.future);
    final trails = (await store.find(db)).map((e) => TrailMetadataModel.fromJson(e.value)).toSet();
    if (trails.isNotEmpty) {
      refresh();
      return trails;
    }
    return await _fetch();
  }

  Future<Set<TrailMetadataModel>> _fetch() async {
    final res = await ref.read(dioProvider).get("/trail/list");

    final List<Map<String, dynamic>> jsonList = [
      for (final json in res.data.values)
        json
    ];

    final db = await ref.read(forestParkDatabaseProvider.future);
    db.transaction((txn) {
      store.delete(db);
      store.addAll(db, jsonList);
    });

    return jsonList.map((json) => TrailMetadataModel.fromJson(json)).toSet();
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
    TrailMetadataModel? closestTrail;
    LatLng? closestLatLng;
    int index = 0;
    await Future.wait(trailList.map((trailMetadata) async {
      final trail = await ref.read(trailProvider(trailMetadata.uuid).future);
      final path = trail.path;
      for (int i=0; i<path.length; i++) {
        final dist = _squareDist(loc, path[i]);
        if (squareDist == null || dist < squareDist!) {
          squareDist = dist;
          closestTrail = trailMetadata;
          closestLatLng = path[i];
          index = i;
        }
      }
    }));

    final snappedLoc = SnappedLatLng(closestTrail!.uuid, index, closestLatLng!);
    final dist = const DistanceVincenty().as(LengthUnit.Meter, loc, snappedLoc);
    return SnappedResult(snappedLoc, dist);
  }
  double _squareDist(LatLng p1, LatLng p2) {
    return pow(p1.latitude-p2.latitude, 2) + pow(p1.longitude-p2.longitude, 2) as double;
  }
}

@riverpod
class Trail extends _$Trail {
  static final store = StoreRef<String, Blob>("trail_data");

  @override
  Future<TrailModel> build(String uuid) async {
    final db = await ref.watch(forestParkDatabaseProvider.future);
    final trailBlob = await store.record(uuid).get(db);
    if (trailBlob == null) {
      return await _fetch();
    }
    refresh();
    return TrailModel.decode(trailBlob.bytes);
  }

  Future<TrailModel> _fetch() async {
    final res = await ref.read(dioProvider).get(
      "/trail/$uuid",
      options: Options(
          responseType: ResponseType.bytes
      ),
    );

    final db = await ref.read(forestParkDatabaseProvider.future);
    store.record(uuid).add(db, Blob(res.data));

    return TrailModel.decode(res.data);
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }
}

@riverpod
class SelectedTrail extends _$SelectedTrail {
  @override
  TrailMetadataModel? build() => null;

  void deselect() => state = null;
  void select(TrailMetadataModel? selection) => state = selection;
}
