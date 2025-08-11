import 'package:flutter/material.dart';
import 'package:forest_park_reports/env.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forest_park_reports/provider/selected_trail_provider.dart';


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
   // debugPrint("mappage is loading");
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final styleUrl = '$kBackendUrl/styles/${lightMode ? 'light' : 'dark'}.json?key=$kProtoApiKey&mobile=true';
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

    
    
  }

  Future<void> _onStyleLoaded() async {
    final routeUrl = '$kBackendUrl/geojson/routes.json';
    final routeResponse = await http.get(Uri.parse(routeUrl));

    if (routeResponse.statusCode == 200) {
      final geoJson = json.decode(routeResponse.body);
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
            lineWidth: 5,
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
    }

    final startMarkerUrl = '$kBackendUrl/geojson/start-markers.json';
    final startMarkerResponse = await http.get(Uri.parse(startMarkerUrl));

    if (startMarkerResponse.statusCode == 200) {
      final rawGeoJson = json.decode(startMarkerResponse.body);

      for (final feature in rawGeoJson['features']) {
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
          GeojsonSourceProperties(data: rawGeoJson),
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
    }

    //hazard markers
    final hazardMarkersUrl = '$kBackendUrl/geojson/reports.json';
    final hazardMarkersResponse = await http.get(Uri.parse(hazardMarkersUrl));

    if (hazardMarkersResponse.statusCode == 200) {
      final rawGeoJson = json.decode(hazardMarkersResponse.body);

      for (final feature in rawGeoJson['features']) {
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
          GeojsonSourceProperties(data: rawGeoJson),
        );
        _controller?.addCircleLayer(
          "hazard-markers",
          "hazard-markers-layer",
          const CircleLayerProperties(
            circleColor: '#FF0000',
            circleRadius: 6,
            circleStrokeWidth: 1,
            circleOpacity: 0.8,
            circleStrokeColor: '#000000',
          ),
        );
      } catch (e) {
        debugPrint("Error adding hazard markers: $e");
      }
    } else {
      debugPrint("Failed to fetch hazard markers: ${hazardMarkersResponse.statusCode}");
    }
    _controller?.onFeatureTapped.add((tappedFeature, pos, coords, layer) async {

      // tappedFeature is the ID of the feature that was tapped.
      // Since our only features are the routes, one of the IDs will match.
       final cleanFeatureId = tappedFeature.toString().split('.').last;
        for (final feature in _routesGeoJson!['features']) {
          final featureId = feature['id'].toString();
        //  debugPrint("Checking feature ID: $featureId against tapped: $cleanFeatureId");

          if (featureId == cleanFeatureId) {
          //  debugPrint("Feature matched: $featureId");
            /*
            setState(() {
              _selectedFeature = feature;
            });
            */
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
            //  "features": [_selectedFeature],
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
          enableInteraction: true
        );
      } catch (e) {
        debugPrint("Highlight layer already exists or error: $e");
      }
    });
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
