import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_marker_popup/src/popup_event.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
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
    final lightMode = WidgetsBinding.instance.window.platformBrightness == Brightness.light;
    // using ref.watch will allow the widget to be rebuilt everytime
    // the provider is updated
    ParkTrails parkTrails = ref.watch(parkTrailsProvider);
    // enable edge to edge mode on android
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: lightMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final centerOnLocation = ref.watch(centerOnLocationProvider);
    ref.listen(centerOnLocationProvider, (prev, next) {
      if (next != prev && next != CenterOnLocationUpdate.never) {
        _centerCurrentLocationStreamController.add(null);
      }
    });

    return FlutterMap(
      options: MapOptions(
        center: LatLng(45.57416784067063, -122.76892379502566),
        zoom: 11.5,
        onPositionChanged: (MapPosition position, bool hasGesture) {
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
            //? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
            //     lightMode
            //         ? "https://api.mapbox.com/styles/v1/ethemoose/cl55mcv4b004u15sbw36oqa8p/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}"
            //         : "https://api.mapbox.com/styles/v1/ethemoose/cl548b3a4000s15tkf8bbw2pt/tiles/512/{z}/{x}/{y}@2x?access_token=${dotenv.env["MAPBOX_KEY"]}",
            maxNativeZoom: 22,
            maxZoom: 22,
          ),
        ),
        // TODO render on top of everything (currently breaks tappable polyline)
        // we'll probably need to handle taps ourselves, shouldn't be too bad
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
              _popupController.hideAllPopups();
              final tag = polylines.first.tag?.split("_").first;
              if (tag == parkTrails.selectedTrail?.uuid) {
                ref.read(parkTrailsProvider.notifier).deselectTrail();
              } else {
                ref.read(parkTrailsProvider.notifier)
                    .selectTrail(parkTrails.trails[tag]!);
              }
            },
            onMiss: (tapPosition) {
              _popupController.hideAllPopups();
              ref.read(parkTrailsProvider.notifier).deselectTrail();
            },
          ),
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            markerRotateOrigin: const Offset(15, 15),
            popupController: _popupController,
            popupBuilder: (_, marker) {
              if (marker is HazardMarker) {
                return HazardInfoPopup(hazard: marker.hazard);
              } else {
                return Container();
              }
            },
            onPopupEvent: (e, __) {
              if (e is ShowPopupsOnlyFor) {
                ref.read(parkTrailsProvider.notifier).deselectTrail();
              }
            },
            popupAnimation: const PopupAnimation.fade(duration: Duration(milliseconds: 100)),
            markers: ref.watch(activeHazardProvider).map((e) => HazardMarker(
              hazard: e,
              builder: (_) => Icon(
                Icons.warning_rounded,
                color: isMaterial(context)
                    ? Theme.of(context).errorColor
                    : CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context)
              ),
            )).toList()
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
          child: Container(
            width: 200,
            height: 100,
          ),
        ),
      )
    );
  }

}

class HazardMarker extends Marker {
  final Hazard hazard;
  HazardMarker({required this.hazard, required super.builder}) : super(point: hazard.location);
}
