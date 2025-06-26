# traileyes_api.api.GeojsonApi

## Load the API package
```dart
import 'package:traileyes_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**geojsonRoutesJsonGet**](GeojsonApi.md#geojsonroutesjsonget) | **GET** /geojson/routes.json | Get all routes as GeoJSON
[**geojsonStartMarkersJsonGet**](GeojsonApi.md#geojsonstartmarkersjsonget) | **GET** /geojson/start-markers.json | Get start markers as GeoJSON


# **geojsonRoutesJsonGet**
> BuiltMap<String, JsonObject> geojsonRoutesJsonGet()

Get all routes as GeoJSON

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getGeojsonApi();

try {
    final response = api.geojsonRoutesJsonGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GeojsonApi->geojsonRoutesJsonGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **geojsonStartMarkersJsonGet**
> BuiltMap<String, JsonObject> geojsonStartMarkersJsonGet()

Get start markers as GeoJSON

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getGeojsonApi();

try {
    final response = api.geojsonStartMarkersJsonGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GeojsonApi->geojsonStartMarkersJsonGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

