import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:gpx/gpx.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:simplify/simplify.dart';

import '../util/length_unit.dart';

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
  int get hashCode => hashValues(name, uuid);
  @override
  String toString() {
    return "$name, uuid:$uuid, ${track?.path.length ?? 0} points";
  }
}

//TODO reduce polyline points client side
//TODO process gpx files server side
/// Represents a GPX file (list of coordinates) in an easy to use way
class Track {
  List<LatLng> path = [];
  List<double> elevation = [];
  List<double> distance = [0];
  double maxElevation = 0;
  double minElevation = double.infinity;
  Track(Gpx path) {
    // loop through every track point and add the coordinates to the path array
    // we also construct a separate elevation array for, the elevation of one
    // coordinate has the same index as the coordinate
    for (var track in path.trks) {
      for (var trackSegment in track.trksegs) {
        for (int i=0; i<trackSegment.trkpts.length; i++) {
          final point = trackSegment.trkpts[i];
          this.path.add(LatLng(point.lat!, point.lon!));
          if (point.ele! > maxElevation) {maxElevation = point.ele!;}
          if (point.ele! < minElevation) {minElevation = point.ele!;}
          if (i>0) {
            distance.add(
                distance[i-1] + this.path[i-1].distanceFrom(this.path[i], LengthUnit.Meter)
            );
          }
          elevation.add(point.ele!);
        }
      }
    }
  }
}

/// Holds a Map of Trails along with a set of polylines and the selected trail
///
/// Polylines are used to render on top of the GoogleMap widget. When a trail
/// is selected, we remove the selected polyline and add in 2 more polylines,
/// one being the trail in a different color, and one being a transparent
/// highlight.
/// The ParkTrails class holds the currently selected polyline
class ParkTrails {
  final Map<String, Trail> trails;
  final Trail? selectedTrail;
  final List<TrackPolyline> trackPolylines;
  final PolylineResolution resolution;
  /// Returns a list of Polylines from the TrailPolylines, adding the main
  /// Polyline for unselected Trails and the 2 selection Polylines
  /// for selected ones
  Set<Polyline> get polylines => trackPolylines
      .map((e) => e.getPolylines(resolution))
      .expand((e) => e)
      .toSet();
  bool get isPopulated => !(trails.isEmpty || polylines.isEmpty);

  ParkTrails({this.trails = const {}, this.resolution = PolylineResolution.min, this.selectedTrail, this.trackPolylines = const []});

  // We need a copyWith function for everything being used in a StateNotifier
  // because riverpod StateNotifier state is immutable
  ParkTrails copyWith({required Trail? selectedTrail, PolylineResolution? resolution, List<TrackPolyline>? trackPolylines}) {
    return ParkTrails(
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
    final dist = loc.distanceFrom(snappedLoc, LengthUnit.Meter);
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
  final Polyline polyline;
  final Polyline selectedPolyline;
  final Polyline highlightPolyline;
  const PolylineSet({
    required this.polyline,
    required this.selectedPolyline,
    required this.highlightPolyline,
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
    if (zoom < 10) {
      return PolylineResolution.min;
    } else if (zoom < 11) {
      return PolylineResolution.low;
    } else if (zoom < 12) {
      return PolylineResolution.medium;
    } else if (zoom < 13.5) {
      return PolylineResolution.high;
    } else if (zoom < 15) {
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
  final void Function(Trail trail) onSelect;
  final void Function() onDeselect;
  /// Returns a list of all polylines that should be displayed
  Set<Polyline> getPolylines(PolylineResolution resolution) {
    polylineSet.putIfAbsent(resolution, () {
      final path = simplify(trail.track!.path, tolerance: resolution.tolerance);
      return PolylineSet(
        polyline: Polyline(
          polylineId: PolylineId(trail.uuid),
          points: path,
          width: 1,
          color: CupertinoColors.activeOrange,
          consumeTapEvents: true,
          onTap: () => onSelect(trail),
        ),
        selectedPolyline: Polyline(
          polylineId: PolylineId("${trail.uuid}_selected"),
          points: path,
          width: 1,
          color: CupertinoColors.activeGreen,
          zIndex: 11,
        ),
        highlightPolyline: Polyline(
          polylineId: PolylineId("${trail.uuid}_highlight"),
          points: path,
          width: 8,
          color: CupertinoColors.activeGreen.withAlpha(80),
          zIndex: 10,
          consumeTapEvents: true,
          onTap: onDeselect,
        ),
      );
    });
    final set = polylineSet[resolution]!;
    return selected ? {set.selectedPolyline, set.highlightPolyline} : {set.polyline};
  }
  // private constructor used to copy without recreating Polylines
  TrackPolyline._fromPolylines(
      this.trail,
      this.selected,
      this.polylineSet,
      this.onSelect,
      this.onDeselect,
  );
  TrackPolyline({
    required this.trail,
    required this.selected,
    required this.onSelect,
    required this.onDeselect
  }) : polylineSet = {};

  TrackPolyline copyWith({bool? selected}) {
    return TrackPolyline._fromPolylines(trail, selected ?? this.selected, polylineSet, onSelect, onDeselect);
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
class RemoteTrailsNotifier extends StateNotifier<Map<String, Trail>> {
  StateNotifierProviderRef ref;
  RemoteTrailsNotifier(this.ref) : super({}) {
    fetchTrails();
  }
  static final GpxReader _gpxReader = GpxReader();
  Future fetchTrails() async {
    final res = await ref.read(dioProvider).get("/trail/list");
    state = {
      for (final val in res.data.values)
        val["uuid"]: Trail(val["name"], val["uuid"])
    };
    for (final trail in state.values) {
      final res = await ref.read(dioProvider).get("/trail/${trail.uuid}");
      final track = Track(_gpxReader.fromString(res.data));
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


class ParkTrailsNotifier extends StateNotifier<ParkTrails> {
  final StateNotifierProviderRef ref;
  // initial state is an empty ParkTrails
  ParkTrailsNotifier(this.ref) : super(ParkTrails()) {
    // watch the raw trail provider for updates. When the trails have been
    // loaded or refreshed it will call _buildPolylines.
    ref.listen(remoteTrailsProvider, (_, Map<String, Trail> trails) => _buildPolylines(trails));
  }

  // builds the TrailPolylines for each Trail and handles selection logic
  // plus updates ParkTrails state
  Future _buildPolylines(Map<String, Trail> trails) async {
    // initial state update
    state = ParkTrails(
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
              onSelect: selectTrail,
              onDeselect: deselectTrail
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
    print(state.resolution);
  }

  void updateZoom(double zoom) {
    final resolution = PolylineResolution.resolutionFromZoom(zoom);
    if (resolution != state.resolution) {
      print(resolution);
      state = state.copyWith(selectedTrail: state.selectedTrail, resolution: resolution);
    }
  }

}

final parkTrailsProvider = StateNotifierProvider<ParkTrailsNotifier, ParkTrails>((ref) {
  return ParkTrailsNotifier(ref);
});
