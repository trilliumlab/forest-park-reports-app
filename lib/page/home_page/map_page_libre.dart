import 'package:flutter/material.dart';
import 'package:forest_park_reports/env.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  void initState() {
    super.initState();
    printEnv();
  }

  @override
  void printEnv() {
    print('Backend URL: ${dotenv.env["BACKEND_URL"]}');
    print('Proto API Key: ${dotenv.env["PROTO_API_KEY"]}');
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Cache style/tiles
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final styleUrl =
        '$kBackendUrl/styles/${lightMode ? 'light' : 'dark'}.json?key=$kProtoApiKey&mobile=true';
    // debugPrint('STYLE URL: $styleUrl');

    return MapLibreMap(
      rotateGesturesEnabled: true,
      styleString:
          '$kBackendUrl/styles/${lightMode ? 'light' : 'dark'}.json?key=$kProtoApiKey&mobile=true',
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
    );
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _controller = controller;

    _controller?.onFeatureTapped.add((tappedFeature, pos, coords, layer) async {
      if (layer == "routes-layer") {
        // tappedFeature is the ID of the feature that was tapped.
        // Since our only features are the routes, one of the IDs will match.
        for (final feature in _routesGeoJson!['features']) {
          final featureId = feature['id'].toString();
          //  debugPrint("Checking feature ID: $featureId against tapped: $cleanFeatureId");

          if (featureId == tappedFeature) {
            //  debugPrint("Feature matched: $featureId");
            // setState(() {
            //   _selectedFeature = feature;
            // });
            ref.read(selectedTrailProvider.notifier).select(feature);
            break;
          }
        }
        await _removeHighlightLayer();

        try {
          await _controller!.addSource(
            'highlight-source',
            GeojsonSourceProperties(
              data: {
                "type": "FeatureCollection",
                "features": [ref.read(selectedTrailProvider)],
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
      } else {
        debugPrint(
            "Tapped feature ${tappedFeature.toString()} in unhandled layer `$layer`");
      }
    });
  }

  Future<void> _onStyleLoaded() async {
    try {
      // Use the route provider to get the parsed GeoJSON data
      final routesData = await ref.read(routeProviderProvider.future);
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
      final startMarkersData =
          await ref.read(startMarkerProviderProvider.future);
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
    final reportsData = await ref.read(reportProviderProvider.future);
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
        "hazard-markers",
        GeojsonSourceProperties(data: geoJson),
      );
      _controller?.addSymbolLayer(
        "hazard-markers",
        "hazard-markers-layer",
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
    //setState(() {
    //_selectedFeature = null;
    //});
    ref.read(selectedTrailProvider.notifier).clear();
    await _removeHighlightLayer();
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
