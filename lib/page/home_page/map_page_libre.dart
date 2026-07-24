import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/env.dart';
import 'package:forest_park_reports/provider/align_position_provider.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'dart:math';
import 'package:turf/turf.dart' show Feature;
import 'package:forest_park_reports/provider/selected_trail_provider.dart';
import 'package:forest_park_reports/provider/geojson_provider.dart';

/// Renders the main map.
///
/// Contains all trails, hazard markers, and hazard info popups.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  MapLibreMapController? _controller;
  //Map<String, dynamic>? _selectedFeature;
  Map<String, dynamic>? _routesGeoJson;

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _selectTrail(Feature trail) async {
    // We clicked a polyline

    // deselect hazards
    ref.read(selectedReportProvider.notifier).clear();

    ref.read(selectedTrailProvider.notifier).select(trail);
    if (ref.read(panelPositionProvider).position.index <=
        PanelState.COLLAPSED.index) {
      ref.read(panelPositionProvider.notifier).move(PanelState.SNAPPED);
    }

    await _removeHighlightLayer();

    try {
      await _controller!.addSource(
        'highlight-source',
        GeojsonSourceProperties(
          data: {
            "type": "FeatureCollection",
            "features": [trail.toJson()],
          },
        ),
      );
    } catch (e) {
      debugPrint("Highlight source already exists or error: $e");
    }

    try {
      await _controller!.addLineLayer(
          'highlight-source',
          'highlight-layer',
          const LineLayerProperties(
            lineColor: '#FFFF33', // highlight color (blue)
            lineWidth: 6,
            lineJoin: 'round',
            lineCap: 'round',
          ),
          enableInteraction: true);
    } catch (e) {
      debugPrint("Highlight layer already exists or error: $e");
    }
  }

  Future<void> _selectReport(Feature report) async {
    // deselect trail
    ref.read(selectedTrailProvider.notifier).clear();

    ref.read(selectedReportProvider.notifier).select(report);
    if (ref.read(panelPositionProvider).position.index <=
        PanelState.COLLAPSED.index) {
      ref.read(panelPositionProvider.notifier).move(PanelState.SNAPPED);
    }

    await _removeHighlightLayer();
  }

  Future<void> _deselect() async {
    // We clicked somewhere that is not a polyline nor hazard.
    // Deselect both
    if (ref.read(panelPositionProvider).position == PanelState.OPEN) {
      ref.read(panelPositionProvider.notifier).move(PanelState.SNAPPED);
    } else {
      ref.read(selectedTrailProvider.notifier).clear();
      ref.read(selectedReportProvider.notifier).clear();
      await _removeHighlightLayer();
      ref.read(panelPositionProvider.notifier).move(PanelState.HIDDEN);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Cache style/tiles
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final styleUrl =
        '$kBackendUrl/styles/${lightMode ? 'light' : 'dark'}.json?key=$kProtoApiKey&mobile=true';

    final followTarget = ref.watch(alignPositionTargetProvider);
    ref.listen(alignPositionTargetProvider, (prev, next) {
      if (next == AlignPositionTargetState.forestPark) {
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(kHomeCameraPosition.center.latitude,
              kHomeCameraPosition.center.longitude),
          kHomeCameraPosition.zoom,
        ));
      } else if (next == AlignPositionTargetState.currentLocation) {
        final position = ref.read(locationProvider).valueOrNull;
        if (position != null) {
          _controller?.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            16,
          ));
        }
      }
    });
    // MapLibre's native location-follow doesn't reliably pan the camera as
    // new GPS fixes arrive (puck position/heading render fine, but the
    // camera itself stays put even while the OS is delivering updates), so
    // drive panning manually off our own geolocator-based location stream
    // while follow mode is active.
    ref.listen(locationProvider, (prev, next) {
      final position = next.valueOrNull;
      if (position != null &&
          ref.read(alignPositionTargetProvider) ==
              AlignPositionTargetState.currentLocation) {
        _controller?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    });

    return MapLibreMap(
      rotateGesturesEnabled: true,
      styleString: styleUrl,
      initialCameraPosition: const CameraPosition(
        target: LatLng(45.5475, -122.755),
        zoom: 10.75,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
      onMapClick: _onMapClick,
      compassViewMargins: const Point(13, 100),
      // TODO: Use custom attribution button/popup
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      attributionButtonMargins: const Point(10, 10),
      myLocationEnabled: true,
      myLocationRenderMode: MyLocationRenderMode.compass,
      myLocationTrackingMode: followTarget == AlignPositionTargetState.currentLocation
          ? MyLocationTrackingMode.tracking
          : MyLocationTrackingMode.none,
      onCameraTrackingDismissed: () {
        // Tracking mode also turns off (and this fires) when we switch to
        // forestPark ourselves; only treat it as a user-initiated dismissal
        // if we were actually following the current location.
        if (ref.read(alignPositionTargetProvider) ==
            AlignPositionTargetState.currentLocation) {
          ref
              .read(alignPositionTargetProvider.notifier)
              .update(AlignPositionTargetState.none);
        }
      },
    );
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _controller = controller;

    _controller?.onFeatureTapped.add((tappedFeature, pos, coords, layer) async {
      switch (layer) {
        case "routes-layer":
          // tappedFeature is the ID of the feature that was tapped.
          // Since our only features are the routes, one of the IDs will match.
          final routes = await ref.read(routeProvider.future);
          for (final route in routes.features) {
            if (route.id.toString() == tappedFeature) {
              // We do not need to check if the route is already selected since
              // The tap would go to the highlight layer instead.
              await _selectTrail(route);
              break;
            }
          }

        case "highlight-layer":
          // Selected trail was tapped, deselect it
          await _deselect();

        case "reports-layer":
          final reports = await ref.read(reportProvider.future);
          for (final report in reports.features) {
            if (report.id.toString() == tappedFeature) {
              if (ref.read(selectedReportProvider)?.id == report.id) {
                // We tapped the selected report, deselect it
                await _deselect();
              } else {
                // We tapped a different report, select it
                await _selectReport(report);
              }
              break;
            }
          }

        default:
          debugPrint(
              "Tapped feature ${tappedFeature.toString()} in unhandled layer `$layer`");
      }
    });
  }

  Future<void> _onStyleLoaded() async {
    try {
      // Use the route provider to get the parsed GeoJSON data
      final routesData = await ref.read(routeProvider.future);
      final geoJson = routesData.toJson();
      _routesGeoJson = geoJson; // Save for manual hit test

      try {
        _controller?.addSource(
          "routes",
          GeojsonSourceProperties(data: geoJson),
        );
        _controller?.addLineLayer(
          "routes",
          "routes-layer",
          const LineLayerProperties(
            lineColor: ['get', 'stroke'],
            lineWidth: 3,
            lineJoin: "round",
            lineCap: "round",
          ),
          // Enables onFeatureTapped for this layer.
          // Touches will not be passed through to the onMapClick handler.
          enableInteraction: true,
        );
      } catch (e) {
        debugPrint("Error adding routes source/layer: $e");
      }
    } catch (e) {
      debugPrint("Error fetching routes: $e");
    }

    try {
      // Use the start marker provider to get the parsed GeoJSON data
      final startMarkersData = await ref.read(startMarkerProvider.future);
      final geoJson = startMarkersData.toJson();

      // Process coordinates if needed (the provider should handle this)
      for (final feature in geoJson['features']) {
        final coords = feature['geometry']['coordinates'];
        if (coords is List && coords.length >= 2) {
          final lon = coords[0];
          final lat = coords[1];
          feature['geometry']['coordinates'] = [lon, lat];
        }
      }

      try {
        _controller?.addSource(
          "start-markers",
          GeojsonSourceProperties(data: geoJson),
        );
        _controller?.addCircleLayer(
          "start-markers",
          "start-markers-layer",
          const CircleLayerProperties(
            circleColor: '#00FF00',
            circleRadius: 6,
            circleOpacity: 0.8,
            circleStrokeWidth: 1,
            circleStrokeColor: '#000000',
          ),
          enableInteraction: false,
        );
      } catch (e) {
        debugPrint("Error adding start-markers source/layer: $e");
      }
    } catch (e) {
      debugPrint("Error fetching start markers: $e");
    }

    // Use the report provider to get the parsed GeoJSON data
    final reportsData = await ref.read(reportProvider.future);
    final geoJson = reportsData.toJson();

    // Process coordinates if needed (the provider should handle this)
    for (final feature in geoJson['features']) {
      final coords = feature['geometry']['coordinates'];
      if (coords is List && coords.length >= 2) {
        final lon = coords[0];
        final lat = coords[1];
        feature['geometry']['coordinates'] = [lon, lat];
      }
    }

    try {
      _controller?.addSource(
        "reports",
        GeojsonSourceProperties(data: geoJson),
      );
      _controller?.addSymbolLayer(
        "reports",
        "reports-layer",
        const SymbolLayerProperties(
          iconImage: 'report_active',
        ),
        enableInteraction: true,
      );
    } catch (e) {
      debugPrint("Error adding hazard markers: $e");
    }
  }

  // Since clicks on routes aren't passed through, any call to this function
  // means the user clicked outside of a route and we should remove the highlight.
  Future<void> _onMapClick(Point<double> point, LatLng coordinates) async {
    await _deselect();
  }

  Future<void> _removeHighlightLayer() async {
    try {
      await _controller?.removeLayer('highlight-layer');
    } catch (e) {
      debugPrint('Error removing highlight-layer: $e');
    }
    try {
      await _controller?.removeSource('highlight-source');
    } catch (e) {
      debugPrint('Error removing highlight-source: $e');
    }
  }
}
