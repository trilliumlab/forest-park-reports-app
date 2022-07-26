import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:forest_park_reports/widgets/hazard_marker.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class ForestParkMap extends ConsumerStatefulWidget {
  const ForestParkMap({Key? key}) : super(key: key);

  @override
  ConsumerState<ForestParkMap> createState() => _ForestParkMapState();
}

class _ForestParkMapState extends ConsumerState<ForestParkMap> with WidgetsBindingObserver {
  // TODO add satallite map style
  final Completer<PlatformMapController> _mapController = Completer();
  final _initialCameraPosition = const CameraPosition(target: LatLng(45.57416784067063, -122.76892379502566), zoom: 11.5);
  CameraPosition _lastCameraPosition = const CameraPosition(target: LatLng(45.57416784067063, -122.76892379502566), zoom: 11.5);
  late StreamController<double?> _centerCurrentLocationStreamController;
  Marker? popupMarker;

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
    final parkTrails = ref.watch(parkTrailsProvider);
    final selectedHazard = ref.watch(selectedHazardProvider);

    final centerOnLocation = ref.watch(centerOnLocationProvider);
    ref.listen(centerOnLocationProvider, (prev, next) {
      if (next != prev && next != CenterOnLocationUpdate.never) {
        _centerCurrentLocationStreamController.add(null);
      }
    });

    final markers = ref.watch(activeHazardProvider).map<Marker>((hazard) {
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
          if (hazard == ref.read(selectedHazardProvider).hazard) {
            ref.read(selectedHazardProvider.notifier).deselect();
          } else {
            ref.read(selectedHazardProvider.notifier).select(hazard);
            final parkTrails = ref.read(parkTrailsProvider);
            final hazardTrail = parkTrails.trails[hazard.location.trail]!;
            ref.read(parkTrailsProvider.notifier).selectTrail(hazardTrail);
          }
        },
      );
      return marker;
    }).toSet();
    if (popupMarker != null) {
      markers.add(popupMarker!);
    }

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
        MarkerInfo(
          getBitmapImage: (img) {
            print('image rendered');
            if (selectedHazard.hazard != null) {
              setState(() {
                popupMarker = Marker(
                  markerId: MarkerId(selectedHazard.hazard!.uuid),
                  position: selectedHazard.hazard!.location,
                  icon: BitmapDescriptor.fromBytes(img),
                );
              });
            }
          },
          hazard: selectedHazard.hazard,
        ),
        PlatformMap(
          compassEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: true,
          polylines: parkTrails.polylines,
          markers: markers,
          onMapCreated: (controller) {
            _mapController.complete(controller);
          },
          onCameraMove: (position) {
            _lastCameraPosition = position;
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
      ],
    );
  }
}
