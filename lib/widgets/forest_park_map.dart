import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/location_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class ForestParkMap extends ConsumerStatefulWidget {
  const ForestParkMap({Key? key}) : super(key: key);

  @override
  ConsumerState<ForestParkMap> createState() => _ForestParkMapState();
}

class _ForestParkMapState extends ConsumerState<ForestParkMap> with WidgetsBindingObserver {
  // TODO add satallite map style
  late final MapController _mapController;
  late final PopupController _popupController;
  late StreamController<double?> _followCurrentLocationStreamController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _popupController = PopupController();
    _followCurrentLocationStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  // listen for brightness change so we can refrash map tiles
  @override
  void didChangePlatformBrightness() {
    setState(() {});
    // // This is a workaround for a bug in flutter_map preventing the
    // // TileLayerOptions reset stream from working. Instead we are rebuilding
    // // every image in the application.
    // // This is ~probably~ definitely causing some visual bugs and needs to be updated asap.
    // // Some light mode tiles are still cached, and show when relaunching the app
    // PaintingBinding.instance.imageCache.clear();
  }

  //TODO move provider consumption out of main widget
  @override
  Widget build(BuildContext context) {
    // using ref.watch will allow the widget to be rebuilt everytime
    // the provider is updated
    // final parkTrails = ref.watch(parkTrailsProvider);
    final locationStatus = ref.watch(locationPermissionStatusProvider);

    final followOnLocation = ref.watch(followOnLocationProvider);
    ref.listen(followOnLocationProvider, (prev, next) {
      if (next != prev && next != FollowOnLocationUpdate.never) {
        _followCurrentLocationStreamController.add(null);
      }
    });

    final markers = ref.watch(activeHazardProvider).map((hazard) {
      late final HazardMarker marker;
      marker = HazardMarker(
        hazard: hazard,
        rotate: true,
        rotateOrigin: const Offset(15, 15),
        builder: (_) =>
          GestureDetector(
            onTap: () {
              ref.read(selectedTrailProvider.notifier).deselect();
              if (hazard == ref.read(selectedHazardProvider).hazard) {
                ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                ref.read(selectedHazardProvider.notifier).deselect();
                _popupController.hideAllPopups();
              } else {
                if (ref.read(panelPositionProvider).position == PanelPositionState.closed) {
                  ref.read(panelPositionProvider.notifier).move(PanelPositionState.snapped);
                }
                ref.read(selectedHazardProvider.notifier).select(hazard);
                _popupController.showPopupsOnlyFor([marker]);
              }
            },
            child: Icon(
              Icons.warning_rounded,
              color: isMaterial(context)
                  ? Theme
                  .of(context)
                  .colorScheme.error
                  : CupertinoDynamicColor.resolve(
                  CupertinoColors.destructiveRed, context)
            ),
          ),
      );
      return marker;
    }).toList();

    ref.listen<SelectedHazardState>(selectedHazardProvider, (prev, next) {
      if (next.hazard == null) {
        _popupController.hideAllPopups();
      } else {
        _popupController.showPopupsOnlyFor(markers.where((e) => e.hazard == next.hazard).toList());
        if (next.moveCamera) {
          _mapController.move(next.hazard!.location, _mapController.zoom);
        }
      }
    });

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: kHomeCameraPosition.center,
        zoom: kHomeCameraPosition.zoom,
        rotation: kHomeCameraPosition.rotation,
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if (position.zoom != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                ref.read(polylineResolutionProvider.notifier)
                    .updateZoom(position.zoom!));
          }
          if (hasGesture) {
            ref.read(followOnLocationProvider.notifier).update((state) => FollowOnLocationUpdate.never);
          }
        },
        maxZoom: 22,
      ),
      children: [
        TileLayer(
          tileProvider: FMTC.instance('forestPark').getTileProvider(),
          backgroundColor: const Color(0xff53634b),
          // lightMode
          //     ? const Color(0xfff7f7f2)
          //     : const Color(0xff36475c),
          urlTemplate: "https://api.mapbox.com/styles/v1/ethemoose/cl5d12wdh009817p8igv5ippy/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
          // urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}@2x",
          // urlTemplate: true
          //         ? "https://api.mapbox.com/styles/v1/ethemoose/cl55mcv4b004u15sbw36oqa8p/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}"
          //         : "https://api.mapbox.com/styles/v1/ethemoose/cl548b3a4000s15tkf8bbw2pt/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
          maxNativeZoom: 22,
          maxZoom: 22,
        ),
        // TODO render on top of everything (currently breaks tappable polyline)
        // we'll probably need to handle taps ourselves, shouldn't be too bad
        if (locationStatus.permission.authorized)
          Consumer(
            builder: (context, ref, _) {
              final positionStream = ref.watch(locationProvider.stream);
              return CurrentLocationLayer(
                followCurrentLocationStream: _followCurrentLocationStreamController.stream,
                followOnLocationUpdate: followOnLocation,
                positionStream: positionStream.map((p) => p.locationMarkerPosition()),
                // Only enable heading on mobile
                // headingStream: (Platform.isAndroid || Platform.isIOS) ? null : const Stream.empty(),
                headingStream: positionStream.map((p) => p.locationMarkerHeading()),
              );
            }
          ),
        const TrailPolylineLayer(),
        const TrailEndsMarkerLayer(),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            popupController: _popupController,
            markers: markers,
            popupDisplayOptions: PopupDisplayOptions(
              builder: (_, marker) {
                if (marker is HazardMarker) {
                  return HazardInfoPopup(hazard: marker.hazard);
                }
                return Container();
              },
              animation: const PopupAnimation.fade(duration: Duration(milliseconds: 100)),
            )
          ),
        ),
      ],
      //TODO attribution, this one looks off
      // nonRotatedChildren: [
      //   AttributionWidget.defaultWidget(
      //     source: 'OpenStreetMap contributors',
      //     onSourceTapped: null,
      //   ),
      // ],
    );
  }
}

class TrailEndsMarkerLayer extends ConsumerWidget {
  const TrailEndsMarkerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trailID = ref.watch(selectedTrailProvider);
    if (trailID == null) {
      return Container();
    }

    final trail = ref.watch(trailProvider(trailID)).value;
    if (trail == null) {
      return Container();
    }

    final prevPoint = trail.geometry[trail.geometry.length-2];
    final bearing = trail.geometry.last.bearingTo(prevPoint);

    return MarkerLayer(
      markers: [
        // End marker
        Marker(
          point: trail.geometry.last,
          builder: (_) => RotationTransition(
            turns: AlwaysStoppedAnimation(bearing/(2*pi)),
            child: const Icon(
              Icons.square,
              color: Colors.red,
              size: 12.0,
            ),
          ),
        ),
        // Start marker
        Marker(
          point: trail.geometry.first,
          builder: (_) => const Icon(
            Icons.circle,
            color: Colors.green,
            size: 12.0,
          ),
        ),
      ],
    );
  }
}

class TrailPolylineLayer extends ConsumerWidget {
  const TrailPolylineLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTrail = ref.watch(selectedTrailProvider);
    final trailList = ref.watch(trailListProvider).value;
    final polylineResolution = ref.watch(polylineResolutionProvider);

    if (trailList == null) {
      return Container();
    }

    return TappablePolylineLayer(
      // Will only render visible polylines, increasing performance
      polylineCulling: true,
      polylines: trailList.map((trailID) {
        final trail = ref.watch(trailProvider(trailID)).value;
        if (trail == null) {
          return null;
        }
        final path = trail.getPath(polylineResolution);

        return selectedTrail == trailID ? TaggedPolyline(
          tag: trailID.toString(),
          points: path,
          strokeWidth: 1.0,
          borderColor: CupertinoColors.activeGreen.withAlpha(80),
          borderStrokeWidth: 8.0,
          color: CupertinoColors.activeGreen,
        ) : TaggedPolyline(
          tag: trailID.toString(),
          points: path,
          strokeWidth: 1.0,
          color: CupertinoColors.activeOrange,
        );
      }).whereNotNull().toList()..sort((a, b) {
        // sorts the list to have selected polylines at the top
        return (a.tag == selectedTrail?.toString() ? 1 : 0) -
        (b.tag == selectedTrail?.toString() ? 1 : 0);
      }),
      onTap: (polylines, tapPosition) {
        // deselect hazards
        ref.read(selectedHazardProvider.notifier).deselect();

        // select polyline
        final tag = polylines.first.tag;
        if (tag == selectedTrail?.toString()) {
          if (ref
              .read(panelPositionProvider)
              .position == PanelPositionState.open
          ) {
            ref.read(panelPositionProvider.notifier).move(
                PanelPositionState.snapped);
          } else {
            ref.read(selectedHazardProvider.notifier).deselect();
            ref.read(selectedTrailProvider.notifier).deselect();
            ref.read(panelPositionProvider.notifier).move(
                PanelPositionState.closed);
          }
        } else {
          ref.read(selectedTrailProvider.notifier)
              .select(trailList.firstWhere((e) => e.toString() == tag));
          if (ref
              .read(panelPositionProvider)
              .position == PanelPositionState.closed) {
            ref.read(panelPositionProvider.notifier).move(
                PanelPositionState.snapped);
          }
        }
      },
      onMiss: (tapPosition) {
        if (ref
            .read(panelPositionProvider)
            .position == PanelPositionState.open) {
          ref.read(panelPositionProvider.notifier).move(
              PanelPositionState.snapped);
        } else {
          ref.read(selectedHazardProvider.notifier).deselect();
          ref.read(selectedTrailProvider.notifier).deselect();
          ref.read(panelPositionProvider.notifier).move(
              PanelPositionState.closed);
        }
      },
    );
  }
}

class HazardInfoPopup extends StatelessWidget {
  final HazardModel hazard;
  const HazardInfoPopup({super.key, required this.hazard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = BorderRadius.all(Radius.circular(8));
    return Container(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          OutlineBoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: PlatformWidgetBuilder(
          cupertino: (context, child, _) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
              child: child,
            ),
          ),
          material: (_, child, __) => Container(
            color: theme.colorScheme.background,
            child: child,
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                  child: Text(
                    hazard.hazard.displayName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: Text(
                    hazard.timeString(),
                  ),
                ),
                // Renders hazard image on popup
                // Consumer(
                //   builder: (context, ref, ___) {
                //     final lastImage = ref.watch(hazardUpdatesProvider(hazard.uuid)).lastImage;
                //     return lastImage != null ? Padding(
                //       padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                //       child: ClipRRect(
                //         borderRadius: radius,
                //         child: AspectRatio(
                //             aspectRatio: 3/4,
                //             child: SizedBox.shrink(
                //               child: HazardImage(lastImage),
                //             )
                //         ),
                //       ),
                //     ) : Container();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HazardImage extends ConsumerWidget {
  final String uuid;
  const HazardImage(this.uuid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(hazardPhotoProvider(uuid));
    final progress = ref.watch(hazardPhotoProgressProvider(uuid)).progress;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: PlatformWidget(
            cupertino: (_, __) => CupertinoActivityIndicator.partiallyRevealed(
              progress: progress,
            ),
            material: (_, __) => CircularProgressIndicator(
              value: progress,
            ),
          ),
        ),
        if (image.hasValue)
          Image.memory(
            image.value!,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}

class HazardMarker extends Marker {
  final HazardModel hazard;
  HazardMarker({required this.hazard, required super.builder, super.rotate, super.rotateOrigin}) : super(point: hazard.location);
}
