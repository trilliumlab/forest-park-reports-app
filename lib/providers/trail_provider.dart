import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:forest_park_reports/models/snapped_latlng.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simplify/simplify.dart';

part 'trail_provider.g.dart';

/// Represents a Trail in Forest Park
class Trail {
  String name;
  String uuid;
  Track? track;
  Trail(this.name, this.uuid, [this.track]);
  Trail copyWith({String? name, String? uuid, Track? track}) {
    return Trail(name ?? this.name, uuid ?? this.uuid, track ?? this.track);
  }

  // Perform equality checks on trail based off only the uuid and name
  // This means two trails with different tracks but the same
  // name and uuid will be considered equal.
  @override
  bool operator ==(Object other) =>
      other is Trail &&
          other.runtimeType == runtimeType &&
          other.name == name &&
          other.uuid == uuid;

  @override
  int get hashCode => Object.hash(name, uuid);
  @override
  String toString() {
    return "$name, uuid:$uuid, ${track?.path.length ?? 0} points";
  }
}

class ColorStop {
  int index;
  Color color;
  ColorStop(this.index, this.color);
  @override
  String toString() => '{index: $index, color: $color}';
}

const haversine = DistanceHaversine(roundResult: false);
/// Represents a GPX file (list of coordinates) in an easy to use way
class Track {
  List<LatLng> path = [];
  List<double> elevation = [];
  List<ColorStop> colors = [];
  List<double> distance = [0];
  double maxElevation = 0;
  double minElevation = double.infinity;
  // tracks the elevation positive delta
  double totalIncline = 0;
  // tracks the elevation negative delta
  double totalDecline = 0;

  // constructs a track from binary encoded track
  Track.decode(Uint8List buffer) {
    final data = buffer.buffer.asByteData();
    // keep track of read position
    var pos = 0;

    // decode trail name
    final nameLength = data.getUint16(pos, Endian.little);
    pos += 2;
    final name = String.fromCharCodes(buffer.getRange(pos, pos+=nameLength));

    // decode colors
    final colorLength = data.getUint16(pos, Endian.little);
    pos += 2;
    final colorEnd = pos + colorLength;
    while (pos < colorEnd) {
      final index = data.getUint16(pos, Endian.little);
      pos += 2;
      final r = data.getUint8(pos++);
      final g = data.getUint8(pos++);
      final b = data.getUint8(pos++);
      colors.add(ColorStop(index, Color.fromARGB(255, r, g, b)));
    }

    // decode path data
    final pathLength = data.getUint16(pos, Endian.little);
    pos += 2;
    final pathEnd = pos + pathLength;
    while (pos < pathEnd) {
      // read latlong
      final latitude = data.getFloat32(pos, Endian.little);
      pos += 4;
      final longitude = data.getFloat32(pos, Endian.little);
      pos += 4;
      final point = LatLng(latitude, longitude);
      // calculate distance and add to array
      if (path.isNotEmpty) {
        distance.add(
            distance.last + haversine
                .as(LengthUnit.Mile, path.last, point)
        );
      }
      // add latlong to path
      path.add(point);

      // read elevation
      final double elevation;
      if (this.elevation.isEmpty) {
        elevation = data.getFloat32(pos, Endian.little);
        pos += 4;
      } else {
        elevation = this.elevation.last + data.getInt8(pos++);
      }
      // calculate max and min elevation + delta
      final delta = elevation - (this.elevation.lastOrNull ?? elevation);
      if (delta >= 0) {
        totalIncline += delta;
        if (elevation > maxElevation) {maxElevation = elevation;}
      }
      if (delta <= 0) {
        totalDecline -= delta;
        if (elevation < minElevation) {minElevation = elevation;}
      }
      // add elevation
      this.elevation.add(elevation);
    }
  }
}

/// Holds a Map of Trails along with a set of polylines and the selected trail
///
/// Polylines are used to render on top of the GoogleMap widget. When a trail
/// is selected, we remove the selected polyline and add in 2 more polylines,
/// one being the trail in a different color, and one being a transparent
/// highlight.
/// The ParkTrailsState class holds the currently selected polyline
class ParkTrailsState {
  final Map<String, Trail> trails;
  final Trail? selectedTrail;
  final List<TrackPolyline> trackPolylines;
  final PolylineResolution resolution;
  /// Returns a list of Polylines from the TrailPolylines, adding the main
  /// Polyline for unselected Trails and the 2 selection Polylines
  /// for selected ones
  List<TaggedPolyline> get polylines => trackPolylines
      .map((e) => e.getPolyline(resolution))
      .toList()..sort((a, b) {
        // sorts the list to have selected polylines at the top, with the
        // selected line first and the highlight second. We do this by
        // assigning a value to each type of polyline, and comparing the
        // difference in values to determine the sort order
        final at = a.tag?.split("_");
        final bt = b.tag?.split("_");
        return (at?.length != 2 ? 0 : at?[1] == "selected" ? 1 : 0) -
            (bt?.length != 2 ? 0 : bt?[1] == "selected" ? 1 : 0);
      }
  );
  List<Marker> get markers => trackPolylines
      .map((e) => e.getMarkers(resolution))
      .expand((e) => e)
      .toList();
  bool get isPopulated => !(trails.isEmpty || polylines.isEmpty);

  ParkTrailsState({this.trails = const {}, this.resolution = PolylineResolution.min, this.selectedTrail, this.trackPolylines = const []});

  // We need a copyWith function for everything being used in a StateNotifier
  // because riverpod StateNotifier state is immutable
  ParkTrailsState copyWith({required Trail? selectedTrail, PolylineResolution? resolution, List<TrackPolyline>? trackPolylines}) {
    return ParkTrailsState(
      trails: trails,
      resolution: resolution ?? this.resolution,
      selectedTrail: selectedTrail,
      trackPolylines: trackPolylines ?? this.trackPolylines,
    );
  }

  // TODO we might need higher resolution here than the closest point
  // This function allows us to snap a location to the closest point on a path.
  SnappedResult snapLocation(LatLng loc) {
    // get all trails with populated tracks
    final trailIter = trails.values.where((t) => t.track != null);
    // this technically won't get an accurate distance as as much
    // as i'd like the earth to be flat, it's not. However, this
    // should be good enough to sort by distance, and it's fast.
    double squareDist = _squareDist(loc, trailIter.first.track!.path.first);
    Trail closest = trailIter.first;
    int index = 0;
    for (final trail in trailIter) {
      final path = trail.track!.path;
      for (int i=0; i<path.length; i++) {
        final dist = _squareDist(loc, path[i]);
        if (dist < squareDist) {
          squareDist = dist;
          closest = trail;
          index = i;
        }
      }
    }
    final snappedLoc = SnappedLatLng(closest.uuid, index, closest.track!.path[index]);
    final dist = const DistanceVincenty().as(LengthUnit.Meter, loc, snappedLoc);
    return SnappedResult(snappedLoc, dist);
  }
  double _squareDist(LatLng p1, LatLng p2) {
    return pow(p1.latitude-p2.latitude, 2) + pow(p1.longitude-p2.longitude, 2) as double;
  }
}

class SnappedResult {
  SnappedLatLng location;
  double distance;
  SnappedResult(this.location, this.distance);
  @override
  String toString() {
    return "snapped $distance meters to $location";
  }
}

class PolylineSet {
  final TaggedPolyline polyline;
  final TaggedPolyline selectedPolyline;
  const PolylineSet({
    required this.polyline,
    required this.selectedPolyline,
  });
}

class MarkerSet {
  final Marker startMarker;
  final Marker endMarker;
  const MarkerSet({
    required this.startMarker,
    required this.endMarker,
  });
}

enum PolylineResolution {
  full,
  ultra,
  high,
  medium,
  low,
  min;

  double get tolerance {
    switch (this) {
      case PolylineResolution.full:
        return 0;
      case PolylineResolution.ultra:
        return 0.00004;
      case PolylineResolution.high:
        return 0.0002;
      case PolylineResolution.medium:
        return 0.0004;
      case PolylineResolution.low:
        return 0.0006;
      case PolylineResolution.min:
        return 0.0008;
    }
  }
  factory PolylineResolution.resolutionFromZoom(double zoom) {
    if (zoom < 11) {
      return PolylineResolution.min;
    } else if (zoom < 12) {
      return PolylineResolution.low;
    } else if (zoom < 13) {
      return PolylineResolution.medium;
    } else if (zoom < 14.5) {
      return PolylineResolution.high;
    } else if (zoom < 16) {
      return PolylineResolution.ultra;
    } else {
      return PolylineResolution.full;
    }
  }
}

/// Holds information for drawing a Trail object in a GoogleMap widget
class TrackPolyline {
  final Trail trail;
  final bool selected;
  final Map<PolylineResolution, PolylineSet> polylineSet;
  /// Returns a list of all polylines that should be displayed
  TaggedPolyline getPolyline(PolylineResolution resolution) {
    polylineSet.putIfAbsent(resolution, () {
      final path = simplify(trail.track!.path, tolerance: resolution.tolerance);
      return PolylineSet(
        polyline: TaggedPolyline(
          tag: trail.uuid,
          points: path,
          strokeWidth: 1.0,
          color: CupertinoColors.activeOrange,
        ),
        selectedPolyline: TaggedPolyline(
          tag: "${trail.uuid}_selected",
          points: path,
          strokeWidth: 1.0,
          borderColor: CupertinoColors.activeGreen.withAlpha(80),
          borderStrokeWidth: 8.0,
          color: CupertinoColors.activeGreen,
        )
      );
    });
    final set = polylineSet[resolution]!;
    return selected ? set.selectedPolyline : set.polyline;
  }
  final Map<PolylineResolution, MarkerSet> markerSet;
  Set<Marker> getMarkers(PolylineResolution resolution) {
    markerSet.putIfAbsent(resolution, () {
      final path = simplify(trail.track!.path, tolerance: resolution.tolerance);
      final prevPoint = path[path.length-2];
      final bearing = path.last.bearingTo(prevPoint);
      return MarkerSet(
        startMarker: Marker(
          point: path.first,
          builder: (_) => const Icon(
            Icons.circle,
            color: Colors.green,
            size: 12.0,
          ),
        ),
        endMarker: Marker(
          point: path.last,
          builder: (_) => RotationTransition(
            turns: AlwaysStoppedAnimation(bearing/(2*pi)),
            child: const Icon(
              Icons.square,
              color: Colors.red,
              size: 12.0,
            ),
          ),
        ),
      );
    });
    final set = markerSet[resolution]!;
    return selected ? {set.startMarker, set.endMarker} : {};
  }
  // private constructor used to copy without recreating Polylines
  TrackPolyline._fromPolylines(
      this.trail,
      this.selected,
      this.polylineSet,
      this.markerSet,
  );
  TrackPolyline({
    required this.trail,
    required this.selected,
  }) : polylineSet = {}, markerSet = {};

  TrackPolyline copyWith({bool? selected}) {
    return TrackPolyline._fromPolylines(trail, selected ?? this.selected, polylineSet, markerSet);
  }
}

//TODO custom markers
// final bitmapsProvider = FutureProvider<List<BitmapDescriptor>>((ref) async {
//   return Future.wait([
//     BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(),
//         'assets/markers/start.png'
//     ),
//     BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(),
//         'assets/markers/end.png'
//     )
//   ]);
// });

// A provider that will load all the trail data from the server
// and can be refreshed to fetch new data.
@riverpod
class RemoteTrails extends _$RemoteTrails {
  @override
  Map<String, Trail> build() {
    fetchTrails();
    return {};
  }
  Future fetchTrails() async {
    final res = await ref.read(dioProvider).get("/trail/list");
    state = {
      for (final val in res.data.values)
        val["uuid"]: Trail(val["name"], val["uuid"])
    };
    for (final trail in state.values) {
      final res = await ref.read(dioProvider).get(
        "/trail/${trail.uuid}",
        options: Options(
            responseType: ResponseType.bytes
        ),
      );
      final track = Track.decode(res.data);
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

@riverpod
class ParkTrails extends _$ParkTrails {
  @override
  ParkTrailsState build() {
    ref.listen(remoteTrailsProvider, (_, Map<String, Trail> trails) => _buildPolylines(trails));
    return ParkTrailsState();
  }

  // builds the TrailPolylines for each Trail and handles selection logic
  // plus updates ParkTrails state
  Future _buildPolylines(Map<String, Trail> trails) async {
    // initial state update
    state = ParkTrailsState(
      trails: trails,
      resolution: state.resolution,
      trackPolylines: [
        for (var trail in trails.values.where((t) => t.track != null))
          if (state.trackPolylines.any((tp) => tp.trail.uuid == trail.uuid))
            state.trackPolylines.firstWhere((tp) => tp.trail.uuid == trail.uuid).copyWith()
          else
            TrackPolyline(
              trail: trail,
              selected: false,
            ),
      ],
    );
  }

  // deselects the selected trail if any and updates state
  // must call on the *notifier*
  void deselectTrail() {
    state = state.copyWith(
      selectedTrail: null,
      trackPolylines: [
        for (final tp in state.trackPolylines) tp.copyWith(selected: false)
      ],
    );
  }

  // selects the trial with the given uuid
  void selectTrail(Trail selected) {
    state = state.copyWith(
      selectedTrail: selected,
      trackPolylines: [
        for (final tp in state.trackPolylines)
          tp.copyWith(selected: tp.trail == selected)
      ],
    );
  }

  void updateZoom(double zoom) {
    final resolution = PolylineResolution.resolutionFromZoom(zoom);
    if (resolution != state.resolution) {
      state = state.copyWith(selectedTrail: state.selectedTrail, resolution: resolution);
    }
  }
}
