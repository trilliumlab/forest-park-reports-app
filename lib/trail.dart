
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';

class Trail {
  String name;
  List<LatLng> path = [];
  List<double> elevation = [];
  Trail(this.name, Gpx path) {
    for (var track in path.trks) {
      for (var trackSegment in track.trksegs) {
        for (var point in trackSegment.trkpts) {
          this.path.add(LatLng(point.lat!, point.lon!));
          elevation.add(point.ele!);
        }
      }
    }
  }
}

final rawTrailsProvider = FutureProvider<Map<String, Trail>>((ref) async {
  // get file path of all gpx files in asset folder
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final List<String> pathPaths = json.decode(manifestContent).keys
      .where((String key) => key.startsWith("assets/trails"))
      .where((String key) => key.contains('.gpx')).toList();

  final Map<String, Trail> trails = {};
  for (var path in pathPaths) {
    path = Uri.decodeFull(path);
    var name = path.split("/")[2];
    trails[name] = (Trail(
        name, GpxReader().fromString(await rootBundle.loadString(path))
    ));
  }

  return trails;
});

class ParkTrails {
  Map<String, Trail> trails;
  String? selectedTrail;
  Set<Polyline> polylines;
  bool get isPopulated => !(trails.isEmpty || polylines.isEmpty);

  ParkTrails({this.trails = const {}, this.selectedTrail, this.polylines = const {}});

  ParkTrails copyWith({String? selectedTrail, Set<Polyline>? polylines}) {
    return ParkTrails(
      trails: trails,
      selectedTrail: selectedTrail ?? this.selectedTrail,
      polylines: polylines ?? this.polylines
    );
  }
}

class ParkTrailsNotifier extends StateNotifier<ParkTrails> {
  final StateNotifierProviderRef ref;
  ParkTrailsNotifier(this.ref) : super(ParkTrails()) {
    _loadBitmaps();
    ref.watch(rawTrailsProvider).whenData(buildPolylines);
  }

  final Completer<List<BitmapDescriptor>> bitmaps = Completer();
  Future _loadBitmaps() async {
    bitmaps.complete(await Future.wait([
      BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/markers/start.png'
      ),
      BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/markers/end.png'
      )
    ]));
  }

  Future buildPolylines(Map<String, Trail> trails) async {
    var bitmaps = await this.bitmaps.future;
    Set<Polyline> polylines = {};
    for (var trail in trails.values) {
      late final Polyline polyline;
      late final Polyline selectedPolyline;
      late final Polyline highlightedPolyline;
      polyline = Polyline(
          polylineId: PolylineId(trail.name),
          points: trail.path,
          width: 2,
          color: Colors.orange,
          consumeTapEvents: true,
          onTap: () {
            state = state.copyWith(
              selectedTrail: trail.name,
              polylines: {
                for (final pl in state.polylines)
                  if (pl.polylineId != polyline.polylineId) pl,
                highlightedPolyline,
                selectedPolyline,
              }
            );
            print("SELECTED ${trail.name}");
          }
      );
      selectedPolyline = polyline.copyWith(
          colorParam: Colors.green,
          startCapParam: Cap.customCapFromBitmap(bitmaps.first),
          endCapParam: Cap.customCapFromBitmap(bitmaps.last),
          zIndexParam: 10,
          onTapParam: () {
            state = state.copyWith(
              selectedTrail: null,
              polylines: {
                for (final pl in state.polylines)
                  if (pl.polylineId != selectedPolyline.polylineId && pl.polylineId != highlightedPolyline.polylineId) pl,
                polyline,
              }
            );
            print("UNSELECTED ${trail.name}");
          },
      );
      highlightedPolyline = Polyline(
        polylineId: PolylineId("${trail.name}_highlight"),
        points: trail.path,
        color: Colors.green.withAlpha(80),
        width: 10,
        zIndex: 2,
      );
      polylines.add(polyline);
    }
    state = ParkTrails(
      trails: trails,
      polylines: polylines
    );
  }
}

final parkTrailsProvider = StateNotifierProvider<ParkTrailsNotifier, ParkTrails>((ref) {
  return ParkTrailsNotifier(ref);
});
