import 'package:forest_park_reports/env.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:turf/turf.dart';

part 'geojson_provider.g.dart';

@Riverpod(keepAlive: true)
Future<FeatureCollection> routeProvider(Ref ref) async {
  final dio = ref.read(dioProvider);

  // Use the backend URL from env.dart for the routes endpoint
  final response = await dio.get('$kBackendUrl/geojson/routes.json');

  if (response.statusCode == 200) {
    try {
      return FeatureCollection.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to parse routes GeoJSON: $e');
    }
  } else {
    throw Exception('Failed to fetch routes: ${response.statusCode}');
  }
}

@Riverpod(keepAlive: true)
Future<FeatureCollection> startMarkerProvider(Ref ref) async {
  final dio = ref.read(dioProvider);

  // Use the backend URL from env.dart for the start markers endpoint
  final response = await dio.get('$kBackendUrl/geojson/start-markers.json');

  if (response.statusCode == 200) {
    try {
      return FeatureCollection.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to parse start markers GeoJSON: $e');
    }
  } else {
    throw Exception('Failed to fetch start markers: ${response.statusCode}');
  }
}

@Riverpod(keepAlive: true)
Future<FeatureCollection> reportProvider(Ref ref) async {
  final dio = ref.read(dioProvider);

  // Use the backend URL from env.dart for the reports endpoint
  final response = await dio.get('$kBackendUrl/geojson/reports.json');

  if (response.statusCode == 200) {
    try {
      return FeatureCollection.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to parse reports GeoJSON: $e');
    }
  } else {
    throw Exception('Failed to fetch reports: ${response.statusCode}');
  }
}
