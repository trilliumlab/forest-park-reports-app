import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/widgets/custom_info_window.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class ForestParkMap extends ConsumerStatefulWidget {
  const ForestParkMap({Key? key}) : super(key: key);

  @override
  ConsumerState<ForestParkMap> createState() => _ForestParkMapState();
}

class _ForestParkMapState extends ConsumerState<ForestParkMap> with WidgetsBindingObserver {
  // TODO add satallite map style
  final Completer<PlatformMapController> _mapController = Completer();
  final _infoWindowController = CustomInfoWindowController();
  final _initialCameraPosition = const CameraPosition(target: LatLng(45.57416784067063, -122.76892379502566), zoom: 11.5);
  CameraPosition _lastCameraPosition = const CameraPosition(target: LatLng(45.57416784067063, -122.76892379502566), zoom: 11.5);
  late StreamController<double?> _centerCurrentLocationStreamController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _centerCurrentLocationStreamController = StreamController<double?>();
    _loadMapStyles().then((value) => didChangePlatformBrightness());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  late String _darkMapStyle;
  late String _lightMapStyle;
  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light.json');
  }

  // listen for brightness change so we can refresh map tiles
  @override
  void didChangePlatformBrightness() async {
    final controller = await _mapController.future;
    if (controller.googleController != null) {
      final theme = WidgetsBinding.instance.window.platformBrightness;
      if (theme == Brightness.dark) {
        controller.googleController!.setMapStyle(_darkMapStyle);
      } else {
        controller.googleController!.setMapStyle(_lightMapStyle);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // using ref.watch will allow the widget to be rebuilt everytime
    // the provider is updated
    ParkTrails parkTrails = ref.watch(parkTrailsProvider);

    final centerOnLocation = ref.watch(centerOnLocationProvider);
    ref.listen(centerOnLocationProvider, (prev, next) {
      if (next != prev && next != CenterOnLocationUpdate.never) {
        _centerCurrentLocationStreamController.add(null);
      }
    });

    final markers = ref.watch(activeHazardProvider).map((hazard) {
      late final HazardMarker marker;
      marker = HazardMarker(
        hazard: hazard,
        // builder: (_) =>
        //   GestureDetector(
        //     onTap: () {
        //       if (hazard == ref.read(selectedHazardProvider).hazard) {
        //         ref.read(selectedHazardProvider.notifier).deselect();
        //         _popupController.hideAllPopups();
        //       } else {
        //         ref.read(selectedHazardProvider.notifier).select(hazard);
        //         final parkTrails = ref.read(parkTrailsProvider);
        //         final hazardTrail = parkTrails.trails[hazard.location.trail]!;
        //         ref.read(parkTrailsProvider.notifier).selectTrail(hazardTrail);
        //         _popupController.showPopupsOnlyFor([marker]);
        //       }
        //     },
        //     child: Icon(
        //       Icons.warning_rounded,
        //       color: isMaterial(context)
        //           ? Theme
        //           .of(context)
        //           .errorColor
        //           : CupertinoDynamicColor.resolve(
        //           CupertinoColors.destructiveRed, context)
        //     ),
        //   ),
        onTap: () {
          _infoWindowController.addInfoWindow!(Text('This is a test'), hazard.location);
        }
      );
      return marker;
    }).toSet();

    ref.listen<SelectedHazard>(selectedHazardProvider, (prev, next) async {
      if (next.hazard == null) {
        // _popupController.hideAllPopups();
      } else {
        // _popupController.showPopupsOnlyFor(markers.where((e) => e.markerId.value == next.hazard.uuid).toList());
        if (next.moveCamera) {
          final controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newLatLng(next.hazard!.location));
        }
      }
    });

    return Stack(
      children: [
        PlatformMap(
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: true,
          polylines: parkTrails.polylines,
          markers: markers,
          onMapCreated: (controller) {
            _infoWindowController.platformMapController = controller;
            _mapController.complete(controller);
          },
          onCameraMove: (position) {
            _lastCameraPosition = position;
            _infoWindowController.onCameraMove!();
            ref.read(parkTrailsProvider.notifier).updateZoom(position.zoom);
          },
          onTap: (tapPosition) {
            if (ref.read(panelPositionProvider).position == PanelPosition.open) {
              ref.read(panelPositionProvider.notifier).move(PanelPosition.snapped);
            } else {
              ref.read(selectedHazardProvider.notifier).deselect();
              ref.read(parkTrailsProvider.notifier).deselectTrail();
              ref.read(panelPositionProvider.notifier).move(PanelPosition.closed);
            }
          },
          // mapType: MapType.satellite,
        ),
        CustomInfoWindow(
          controller: _infoWindowController,
          height: 75,
          width: 150,
          offset: 50,
        ),
      ],
    );

  //   return FlutterMap(
  //     mapController: _mapController,
  //     options: MapOptions(
  //       center: LatLng(45.57416784067063, -122.76892379502566),
  //       zoom: 11.5,
  //       onPositionChanged: (MapPosition position, bool hasGesture) {
  //         if (position.zoom != null) {
  //           WidgetsBinding.instance.addPostFrameCallback((_) =>
  //               ref.read(parkTrailsProvider.notifier).updateZoom(position.zoom!));
  //         }
  //         if (hasGesture) {
  //           ref.read(centerOnLocationProvider.notifier).update((state) => CenterOnLocationUpdate.never);
  //         }
  //       },
  //       maxZoom: 22,
  //     ),
  //     children: [
  //       TileLayerWidget(
  //         options: TileLayerOptions(
  //           tileProvider: FMTC.instance('forestPark').getTileProvider(),
  //           backgroundColor: const Color(0xff53634b),
  //           // lightMode
  //           //     ? const Color(0xfff7f7f2)
  //           //     : const Color(0xff36475c),
  //           urlTemplate: "https://api.mapbox.com/styles/v1/ethemoose/cl5d12wdh009817p8igv5ippy/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
  //           // urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}@2x",
  //           // urlTemplate: true
  //           //         ? "https://api.mapbox.com/styles/v1/ethemoose/cl55mcv4b004u15sbw36oqa8p/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}"
  //           //         : "https://api.mapbox.com/styles/v1/ethemoose/cl548b3a4000s15tkf8bbw2pt/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
  //           maxNativeZoom: 22,
  //           maxZoom: 22,
  //         ),
  //       ),
  //       // TODO render on top of everything (currently breaks tappable polyline)
  //       // we'll probably need to handle taps ourselves, shouldn't be too bad
  //       LocationMarkerLayerWidget(
  //         plugin: LocationMarkerPlugin(
  //           centerCurrentLocationStream: _centerCurrentLocationStreamController.stream,
  //           centerOnLocationUpdate: centerOnLocation,
  //         ),
  //       ),
  //       TappablePolylineLayerWidget(
  //         options: TappablePolylineLayerOptions(
  //           // Will only render visible polylines, increasing performance
  //           polylineCulling: true,
  //           polylines: parkTrails.polylines,
  //           onTap: (polylines, tapPosition) {
  //             _popupController.hideAllPopups();
  //             final tag = polylines.first.tag?.split("_").first;
  //             if (tag == parkTrails.selectedTrail?.uuid) {
  //               ref.read(parkTrailsProvider.notifier).deselectTrail();
  //             } else {
  //               ref.read(parkTrailsProvider.notifier)
  //                   .selectTrail(parkTrails.trails[tag]!);
  //             }
  //           },
  //           onMiss: (tapPosition) {
  //             if (ref.read(panelPositionProvider).position == PanelPosition.open) {
  //               ref.read(panelPositionProvider.notifier).move(PanelPosition.snapped);
  //             } else {
  //               ref.read(selectedHazardProvider.notifier).deselect();
  //               ref.read(parkTrailsProvider.notifier).deselectTrail();
  //               ref.read(panelPositionProvider.notifier).move(PanelPosition.closed);
  //             }
  //           },
  //         ),
  //       ),
  //       PopupMarkerLayerWidget(
  //         options: PopupMarkerLayerOptions(
  //           markerRotateOrigin: const Offset(15, 15),
  //           popupController: _popupController,
  //           popupBuilder: (_, marker) {
  //             if (marker is HazardMarker) {
  //               return HazardInfoPopup(hazard: marker.hazard);
  //             }
  //             return Container();
  //           },
  //           popupAnimation: const PopupAnimation.fade(duration: Duration(milliseconds: 100)),
  //           markers: markers,
  //         ),
  //       )
  //     ],
  //     //TODO attribution, this one looks off
  //     // nonRotatedChildren: [
  //     //   AttributionWidget.defaultWidget(
  //     //     source: 'OpenStreetMap contributors',
  //     //     onSourceTapped: null,
  //     //   ),
  //     // ],
  //   );
    }
}

class HazardInfoPopup extends StatelessWidget {
  final Hazard hazard;
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
                if (hazard.image != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: AspectRatio(
                        aspectRatio: 3/4,
                        child: SizedBox.shrink(
                          child: HazardImage(hazard.image!),
                        )
                      ),
                    ),
                  ),
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
  final Hazard hazard;
  HazardMarker({required this.hazard, super.icon, super.onTap}) : super(markerId: MarkerId(hazard.uuid), position: hazard.location);
}
