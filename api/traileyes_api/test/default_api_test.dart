import 'package:test/test.dart';
import 'package:traileyes_api/traileyes_api.dart';

/// tests for DefaultApi
void main() {
  final instance = TraileyesApi().getDefaultApi();

  group(DefaultApi, () {
    // Get all reports as GeoJSON
    //
    //Future<BuiltMap<String, JsonObject>> geojsonGetReports() async
    test('test geojsonGetReports', () async {
      // TODO
    });

    // Get all routes as GeoJSON
    //
    //Future<BuiltMap<String, JsonObject>> geojsonGetRoutes() async
    test('test geojsonGetRoutes', () async {
      // TODO
    });

    // Get all start markers as GeoJSON
    //
    //Future<BuiltMap<String, JsonObject>> geojsonGetStartMarkers() async
    test('test geojsonGetStartMarkers', () async {
      // TODO
    });

    // Submit a new report
    //
    //Future<ReportsPostReport200Response> reportsPostReport(ReportsPostReportRequest reportsPostReportRequest) async
    test('test reportsPostReport', () async {
      // TODO
    });

    // Get a sprite JSON/PNG
    //
    //Future<SpritesGetSprite200Response> spritesGetSprite(JsonObject path) async
    test('test spritesGetSprite', () async {
      // TODO
    });

    // Get dark style
    //
    //Future<BuiltMap<String, JsonObject>> stylesGetDarkStyle(JsonObject key, { JsonObject mobile }) async
    test('test stylesGetDarkStyle', () async {
      // TODO
    });

    // Get light style
    //
    //Future<BuiltMap<String, JsonObject>> stylesGetLightStyle(String key, { JsonObject mobile }) async
    test('test stylesGetLightStyle', () async {
      // TODO
    });
  });
}
