
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

class TrailsNotifier extends StateNotifier<Set<Polyline>> {
  TrailsNotifier() : super({}) {
    print("TRAILS NOTIFIER BEING CONSTRUCTED");
    loadGpx();
  }

  Future loadGpx() async {
    print("LOADING GPX");
    // get file path of all gpx files in asset folder
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    List<String> pathPaths = json.decode(manifestContent).keys
        .where((String key) => key.startsWith("assets/trails"))
        .where((String key) => key.contains('.gpx')).toList();

    var bitmaps = await Future.wait([
      BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/markers/start.png'
      ),
      BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/markers/end.png'
      )
    ]);

    Set<Polyline> polylines = {};

    for (var path in pathPaths) {
      path = Uri.decodeFull(path);
      var trail = Trail(
          path.split("/")[2],
          GpxReader().fromString(await rootBundle.loadString(path))
      );
      late final Polyline polyline;
      late final Polyline selectedPolyline;
      polyline = Polyline(
          polylineId: PolylineId(trail.name),
          points: trail.path,
          width: 2,
          color: Colors.orange,
          consumeTapEvents: true,
          onTap: () {
            state = {
              for (final pl in state)
                if (pl.polylineId != polyline.polylineId) pl,
              selectedPolyline,
            };
            print("SELECTED ${trail.name}");
          }
      );
      selectedPolyline = polyline.copyWith(
          colorParam: Colors.green,
          startCapParam: Cap.customCapFromBitmap(bitmaps.first),
          endCapParam: Cap.customCapFromBitmap(bitmaps.last),
          zIndexParam: 10,
          onTapParam: () {
            state = {
              for (final pl in state)
                if (pl.polylineId != selectedPolyline.polylineId) pl,
              polyline,
            };
            print("UNSELECTED ${trail.name}");
          }
      );
      polylines.add(polyline);
    }
    state = polylines;
  }
}

final trailsProvider = StateNotifierProvider<TrailsNotifier, Set<Polyline>>((ref) {
  return TrailsNotifier();
});
