import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';

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

const haversine = DistanceHaversine(roundResult: false);
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
                distance[i-1] + haversine
                    .as(LengthUnit.Mile, this.path[i-1], this.path[i])
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
  Map<String, Trail> trails;
  Trail? selectedTrail;
  List<TrackPolyline> trackPolylines;
  /// Returns a list of Polylines from the TrailPolylines, adding the main
  /// Polyline for unselected Trails and the 2 selection Polylines
  /// for selected ones
  List<TaggedPolyline> get polylines => trackPolylines
      .map((e) => e.polylines)
      .expand((e) => e)
      .toList()..sort((a, b) {
        // sorts the list to have selected polylines at the top, with the
        // selected line first and the highlight second. We do this by
        // assigning a value to each type of polyline, and comparing the
        // difference in values to determine the sort order
        final at = a.tag?.split("_");
        final bt = b.tag?.split("_");
        return (at?.length != 2 ? 0 : at?[1] == "selected" ? 2 : at?[1] == "highlight" ? 1 : 0) -
            (bt?.length != 2 ? 0 : bt?[1] == "selected" ? 2 : bt?[1] == "highlight" ? 1 : 0);
      }
  );
  bool get isPopulated => !(trails.isEmpty || polylines.isEmpty);

  ParkTrails({this.trails = const {}, this.selectedTrail, this.trackPolylines = const []});

  // We need a copyWith function for everything being used in a StateNotifier
  // because riverpod StateNotifier state is immutable
  ParkTrails copyWith({required Trail? selectedTrail, List<TrackPolyline>? trackPolylines}) {
    return ParkTrails(
      trails: trails,
      selectedTrail: selectedTrail,
      trackPolylines: trackPolylines ?? this.trackPolylines
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

/// Holds information for drawing a Trail object in a GoogleMap widget
class TrackPolyline {
  final Trail trail;
  final bool selected;
  late final TaggedPolyline polyline;
  late final TaggedPolyline selectedPolyline;
  late final TaggedPolyline highlightPolyline;
  /// Returns a list of all polylines that should be displayed
  Set<TaggedPolyline> get polylines => selected ? {selectedPolyline, highlightPolyline} : {polyline};
  // private constructor used to copy without recreating Polylines
  TrackPolyline._fromPolylines(
      this.trail,
      this.selected,
      this.polyline,
      this.selectedPolyline,
      this.highlightPolyline,
  );
  TrackPolyline({
    required this.trail,
    required this.selected,
  }) {
    // this is the polyline that will be shown when not selected
    polyline = TaggedPolyline(
      tag: trail.uuid,
      points: trail.track!.path,
      strokeWidth: 2.0,
      color: Colors.orange,
    );
    // these two are when selected
    selectedPolyline = TaggedPolyline(
      tag: "${trail.uuid}_selected",
      points: trail.track!.path,
      strokeWidth: 2.0,
      color: Colors.green,
    );
    highlightPolyline = TaggedPolyline(
      tag: "${trail.uuid}_highlight",
      points: trail.track!.path,
      strokeWidth: 10.0,
      color: Colors.green.withAlpha(80),
    );
  }
  TrackPolyline copyWith({bool? selected}) {
    return TrackPolyline._fromPolylines(trail, selected ?? this.selected, polyline, selectedPolyline, highlightPolyline);
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
  // initial state is an empty ParkTrails
  ParkTrailsNotifier(StateNotifierProviderRef ref) : super(ParkTrails()) {
    // watch the raw trail provider for updates. When the trails have been
    // loaded or refreshed it will call _buildPolylines.
    var remoteTrails = ref.watch(remoteTrailsProvider);
    _buildPolylines(remoteTrails);
  }

  // builds the TrailPolylines for each Trail and handles selection logic
  // plus updates ParkTrails state
  Future _buildPolylines(Map<String, Trail> trails) async {
    // initial state update
    state = ParkTrails(
      trails: trails,
      trackPolylines: [
        for (var trail in trails.values.where((t) => t.track != null))
          TrackPolyline(
            trail: trail,
            selected: false,
          )
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

}

final parkTrailsProvider = StateNotifierProvider<ParkTrailsNotifier, ParkTrails>((ref) {
  return ParkTrailsNotifier(ref);
});
