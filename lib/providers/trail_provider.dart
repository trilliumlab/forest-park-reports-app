import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/providers/http_provider.dart';
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
}

/// Represents a GPX file (list of coordinates) in an easy to use way
class Track {
  List<LatLng> path = [];
  List<double> elevation = [];
  Track(Gpx path) {
    // loop through every track point and add the coordinates to the path array
    // we also construct a separate elevation array for, the elevation of one
    // coordinate has the same index as the coordinate
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

/// Holds a Map of Trails along with a set of polylines and the selected trail
///
/// Polylines are used to render on top of the GoogleMap widget. When a trail
/// is selected, we remove the selected polyline and add in 2 more polylines,
/// one being the trail in a different color, and one being a transparent
/// highlight.
/// The ParkTrails class holds the currently selected polyline
class ParkTrails {
  Map<String, Trail> trails;
  String? selectedTrail;
  Set<TrackPolyline> trackPolylines;
  /// Returns a list of Polylines from the TrailPolylines, adding the main
  /// Polyline for unselected Trails and the 2 selection Polylines
  /// for selected ones
  Set<Polyline> get polylines => trackPolylines.map((e) => e.polylines).expand((e) => e).toSet();
  bool get isPopulated => !(trails.isEmpty || polylines.isEmpty);

  ParkTrails({this.trails = const {}, this.selectedTrail, this.trackPolylines = const {}});

  // We need a copyWith function for everything being used in a StateNotifier
  // because riverpod StateNotifier state is immutable
  ParkTrails copyWith({required String? selectedTrail, Set<TrackPolyline>? trackPolylines}) {
    return ParkTrails(
      trails: trails,
      selectedTrail: selectedTrail,
      trackPolylines: trackPolylines ?? this.trackPolylines
    );
  }
}

/// Holds information for drawing a Trail object in a GoogleMap widget
class TrackPolyline {
  /// Returns a list of all polylines that should be displayed
  Set<Polyline> get polylines => selected ? {selectedPolyline, highlightPolyline} : {polyline};
  final bool selected;
  late final Polyline polyline;
  late final Polyline selectedPolyline;
  late final Polyline highlightPolyline;
  // private constructor used to copy without recreating Polylines
  TrackPolyline._fromPolylines(
      this.selected,
      this.polyline,
      this.selectedPolyline,
      this.highlightPolyline,
  );
  TrackPolyline({
    required Track track,
    required this.selected,
    required ValueSetter<bool> onSelect,
  }) {
    // this is the polyline that will be shown when not selected
    // polyline = Polyline(
    //     points: track.path,
    //     strokeWidth: 2,
    //     color: Colors.orange,
    //     onTap: () {
    //       // we pass back the selection to the notifier in a callback
    //       onSelect(true);
    //     }
    // );
    // // these two are when selected
    // // zIndex above highlight polyline to show above
    // selectedPolyline = polyline.copyWith(
    //   colorParam: Colors.green,
    //   startCapParam: startCap != null ? Cap.customCapFromBitmap(startCap) : null,
    //   endCapParam: endCap != null ? Cap.customCapFromBitmap(endCap) : null,
    //   zIndexParam: 10,
    //   onTapParam: () {
    //     onSelect(false);
    //   },
    // );
    // highlightPolyline = Polyline(
    //   polylineId: PolylineId("${id}_highlight"),
    //   points: track.path,
    //   color: Colors.green.withAlpha(80),
    //   width: 10,
    //   zIndex: 2,
    // );
  }
  TrackPolyline copyWith(bool? selected) {
    return TrackPolyline._fromPolylines(selected ?? this.selected, polyline, selectedPolyline, highlightPolyline);
  }
}

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

class ParkTrailsNotifier extends StateNotifier<ParkTrails> {
  // initial state is an empty ParkTrails
  ParkTrailsNotifier(StateNotifierProviderRef ref) : super(ParkTrails()) {
    // // we need to load the asset files for the end caps
    // //TODO test endcaps on android
    // var bitmaps = ref.watch(bitmapsProvider);
    // // watch the raw trail provider for updates. When the trails have been
    // // loaded or refreshed it will call _buildPolylines.
    // var remoteTrails = ref.watch(remoteTrailsProvider);
    // _buildPolylines(remoteTrails, bitmaps.valueOrNull);
  }

  // // builds the TrailPolylines for each Trail and handles selection logic
  // // plus updates ParkTrails state
  // Future _buildPolylines(Map<String, Trail> trails, List<BitmapDescriptor>? bitmaps) async {
  //   Set<TrackPolyline> trailPolylines = {};
  //   for (var trail in trails.values.where((t) => t.track != null)) {
  //     late TrackPolyline trackPolyline;
  //     trackPolyline = TrackPolyline(
  //         id: trail.uuid,
  //         track: trail.track!,
  //         selected: false,
  //         startCap: bitmaps?.first,
  //         endCap: bitmaps?.last,
  //         onSelect: (selected) {
  //           if (selected) {
  //             // when we've selected this trail, we should create a new copy
  //             // of the state with this TrailPolyline copied as selected
  //             state = state.copyWith(
  //               selectedTrail: trail.uuid,
  //               trackPolylines: {
  //                 for (final tp in state.trackPolylines)
  //                   if (tp.polyline.polylineId.value == trail.uuid)
  //                     tp.copyWith(true)
  //                   else
  //                     tp.copyWith(false)
  //               },
  //             );
  //           } else {
  //             // when we've unselected this trail, we need to remove the
  //             // selectedTrail and update the TrailPolyline
  //             state = state.copyWith(
  //               selectedTrail: null,
  //               trackPolylines: {
  //                 for (final tp in state.trackPolylines) tp.copyWith(false)
  //               },
  //             );
  //           }
  //         }
  //     );
  //     trailPolylines.add(trackPolyline);
  //   }
  //   // initial state update
  //   state = ParkTrails(
  //       trails: trails,
  //       trackPolylines: trailPolylines
  //   );
  // }
  //
  // // function on the notifier which deselects all trails and updates state
  // void deselectTrails() {
  //   state = state.copyWith(
  //     selectedTrail: null,
  //     trackPolylines: {
  //       for (final tp in state.trackPolylines) tp.copyWith(false)
  //     },
  //   );
  // }

}

final parkTrailsProvider = StateNotifierProvider<ParkTrailsNotifier, ParkTrails>((ref) {
  return ParkTrailsNotifier(ref);
});
