import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/location_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class ForestParkMap extends ConsumerStatefulWidget {
  const ForestParkMap({Key? key}) : super(key: key);

  @override
  ConsumerState<ForestParkMap> createState() => _ForestParkMapState();
}

class _ForestParkMapState extends ConsumerState<ForestParkMap> with WidgetsBindingObserver {
  // TODO add satallite map style
  // TODO set initial camera position to be centered on ForestPark
  late final MapController _mapController;
  late final PopupController _popupController;
  late StreamController<double?> _centerCurrentLocationStreamController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _popupController = PopupController();
    _centerCurrentLocationStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  // listen for brightness change so we can refrash map tiles
  @override
  void didChangePlatformBrightness() {
    setState(() {});
    // This is a workaround for a bug in flutter_map preventing the
    // TileLayerOptions reset stream from working. Instead we are rebuilding
    // every image in the application.
    // This is ~probably~ definitely causing some visual bugs and needs to be updated asap.
    // Some light mode tiles are still cached, and show when relaunching the app
    PaintingBinding.instance.imageCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    // using ref.watch will allow the widget to be rebuilt everytime
    // the provider is updated
    final parkTrails = ref.watch(parkTrailsProvider);
    final locationStatus = ref.watch(locationPermissionProvider);

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
        builder: (_) =>
          GestureDetector(
            onTap: () {
              ref.read(parkTrailsProvider.notifier).deselectTrail();
              if (hazard == ref.read(selectedHazardProvider).hazard) {
                ref.read(selectedHazardProvider.notifier).deselect();
                _popupController.hideAllPopups();
              } else {
                ref.read(selectedHazardProvider.notifier).select(hazard);
                _popupController.showPopupsOnlyFor([marker]);
              }
            },
            child: Icon(
              Icons.warning_rounded,
              color: isMaterial(context)
                  ? Theme
                  .of(context)
                  .errorColor
                  : CupertinoDynamicColor.resolve(
                  CupertinoColors.destructiveRed, context)
            ),
          ),
      );
      return marker;
    }).toList();

    ref.listen<SelectedHazard>(selectedHazardProvider, (prev, next) {
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
        center: LatLng(45.57416784067063, -122.76892379502566),
        zoom: 11.5,
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if (position.zoom != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                ref.read(parkTrailsProvider.notifier).updateZoom(position.zoom!));
          }
          if (hasGesture) {
            ref.read(centerOnLocationProvider.notifier).update((state) => CenterOnLocationUpdate.never);
          }
        },
        maxZoom: 22,
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
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
        ),
        // TODO render on top of everything (currently breaks tappable polyline)
        // we'll probably need to handle taps ourselves, shouldn't be too bad
        if (locationStatus.permission.authorized)
          LocationMarkerLayerWidget(
            plugin: LocationMarkerPlugin(
              centerCurrentLocationStream: _centerCurrentLocationStreamController.stream,
              centerOnLocationUpdate: centerOnLocation,
            ),
          ),
        TappablePolylineLayerWidget(
          options: TappablePolylineLayerOptions(
            // Will only render visible polylines, increasing performance
            polylineCulling: true,
            polylines: parkTrails.polylines,
            onTap: (polylines, tapPosition) {
              // deselect hazards
              _popupController.hideAllPopups();
              ref.read(selectedHazardProvider.notifier).deselect();

              // select polyline
              final tag = polylines.first.tag?.split("_").first;
              if (tag == parkTrails.selectedTrail?.uuid) {
                ref.read(parkTrailsProvider.notifier).deselectTrail();
              } else {
                ref.read(parkTrailsProvider.notifier)
                    .selectTrail(parkTrails.trails[tag]!);
              }
            },
            onMiss: (tapPosition) {
              if (ref.read(panelPositionProvider).position == PanelPosition.open) {
                ref.read(panelPositionProvider.notifier).move(PanelPosition.snapped);
              } else {
                ref.read(selectedHazardProvider.notifier).deselect();
                ref.read(parkTrailsProvider.notifier).deselectTrail();
                ref.read(panelPositionProvider.notifier).move(PanelPosition.closed);
              }
            },
          ),
        ),
        MarkerLayerWidget(
          options: MarkerLayerOptions(
            markers: parkTrails.markers,
          ),
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            markerRotateOrigin: const Offset(15, 15),
            popupController: _popupController,
            popupBuilder: (_, marker) {
              if (marker is HazardMarker) {
                return HazardInfoPopup(hazard: marker.hazard);
              }
              return Container();
            },
            popupAnimation: const PopupAnimation.fade(duration: Duration(milliseconds: 100)),
            markers: markers,
          ),
        )
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
  HazardMarker({required this.hazard, required super.builder}) : super(point: hazard.location);
}
