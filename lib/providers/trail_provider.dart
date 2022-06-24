import 'dart:async';
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
  Set<TrailPolyline> trailPolylines;
  Set<Polyline> get polylines => trailPolylines.map((e) => e.polylines).expand((e) => e).toSet();
  bool get isPopulated => !(trails.isEmpty || polylines.isEmpty);

  ParkTrails({this.trails = const {}, this.selectedTrail, this.trailPolylines = const {}});

  ParkTrails copyWith({required String? selectedTrail, Set<TrailPolyline>? trailPolylines}) {
    return ParkTrails(
      trails: trails,
      selectedTrail: selectedTrail,
      trailPolylines: trailPolylines ?? this.trailPolylines
    );
  }
}

class TrailPolyline {
  Set<Polyline> get polylines => selected ? {selectedPolyline, highlightedPolyline} : {polyline};
  final bool selected;
  late final Polyline polyline;
  late final Polyline selectedPolyline;
  late final Polyline highlightedPolyline;
  TrailPolyline._fromPolylines(
      this.selected,
      this.polyline,
      this.selectedPolyline,
      this.highlightedPolyline,
  );
  TrailPolyline({
    required Trail trail,
    required this.selected,
    required BitmapDescriptor startCap,
    required BitmapDescriptor endCap,
    required ValueSetter<bool> onSelect,
  }) {
    polyline = Polyline(
        polylineId: PolylineId(trail.name),
        points: trail.path,
        width: 2,
        color: Colors.orange,
        consumeTapEvents: true,
        onTap: () {
          onSelect(true);
        }
    );
    selectedPolyline = polyline.copyWith(
      colorParam: Colors.green,
      startCapParam: Cap.customCapFromBitmap(startCap),
      endCapParam: Cap.customCapFromBitmap(endCap),
      zIndexParam: 10,
      onTapParam: () {
        onSelect(false);
      },
    );
    highlightedPolyline = Polyline(
      polylineId: PolylineId("${trail.name}_highlight"),
      points: trail.path,
      color: Colors.green.withAlpha(80),
      width: 10,
      zIndex: 2,
    );
  }
  TrailPolyline copyWith(bool? selected) {
    return TrailPolyline._fromPolylines(selected ?? this.selected, polyline, selectedPolyline, highlightedPolyline);
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
    Set<TrailPolyline> trailPolylines = {};
    for (var trail in trails.values) {
      late TrailPolyline trailPolyline;
      trailPolyline = TrailPolyline(
          trail: trail,
          selected: false,
          startCap: bitmaps.first,
          endCap: bitmaps.last,
          onSelect: (selected) {
            if (selected) {
              state = state.copyWith(
                selectedTrail: trail.name,
                trailPolylines: {
                  for (var tp in state.trailPolylines)
                    if (tp.polyline.polylineId.value == trail.name)
                      tp.copyWith(true)
                    else
                      tp.copyWith(false)
                },
              );
            } else {
              state = state.copyWith(
                selectedTrail: null,
                trailPolylines: {
                  for (var tp in state.trailPolylines) tp.copyWith(false)
                },
              );
            }
          }
      );
      trailPolylines.add(trailPolyline);
    }
    state = ParkTrails(
        trails: trails,
        trailPolylines: trailPolylines
    );
  }
}

final parkTrailsProvider = StateNotifierProvider<ParkTrailsNotifier, ParkTrails>((ref) {
  return ParkTrailsNotifier(ref);
});
