# traileyes_api.api.DefaultApi

## Load the API package
```dart
import 'package:traileyes_api/api.dart';
```

All URIs are relative to *http://api.nightly.traileyes.net*

Method | HTTP request | Description
------------- | ------------- | -------------
[**geojsonGetReports**](DefaultApi.md#geojsongetreports) | **GET** /geojson/reports.json | Get all reports as GeoJSON
[**geojsonGetRoutes**](DefaultApi.md#geojsongetroutes) | **GET** /geojson/routes.json | Get all routes as GeoJSON
[**geojsonGetStartMarkers**](DefaultApi.md#geojsongetstartmarkers) | **GET** /geojson/start-markers.json | Get all start markers as GeoJSON
[**reportsPostReport**](DefaultApi.md#reportspostreport) | **POST** /reports/report | Submit a new report
[**spritesGetSprite**](DefaultApi.md#spritesgetsprite) | **GET** /sprites/{path} | Get a sprite JSON/PNG
[**stylesGetDarkStyle**](DefaultApi.md#stylesgetdarkstyle) | **GET** /styles/dark.json | Get dark style
[**stylesGetLightStyle**](DefaultApi.md#stylesgetlightstyle) | **GET** /styles/light.json | Get light style


# **geojsonGetReports**
> BuiltMap<String, JsonObject> geojsonGetReports()

Get all reports as GeoJSON

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();

try {
    final response = api.geojsonGetReports();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->geojsonGetReports: $e\n');
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

# **geojsonGetRoutes**
> BuiltMap<String, JsonObject> geojsonGetRoutes()

Get all routes as GeoJSON

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();

try {
    final response = api.geojsonGetRoutes();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->geojsonGetRoutes: $e\n');
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

# **geojsonGetStartMarkers**
> BuiltMap<String, JsonObject> geojsonGetStartMarkers()

Get all start markers as GeoJSON

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();

try {
    final response = api.geojsonGetStartMarkers();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->geojsonGetStartMarkers: $e\n');
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

# **reportsPostReport**
> ReportsPostReport200Response reportsPostReport(reportsPostReportRequest)

Submit a new report

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();
final ReportsPostReportRequest reportsPostReportRequest = ; // ReportsPostReportRequest | 

try {
    final response = api.reportsPostReport(reportsPostReportRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->reportsPostReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportsPostReportRequest** | [**ReportsPostReportRequest**](ReportsPostReportRequest.md)|  | 

### Return type

[**ReportsPostReport200Response**](ReportsPostReport200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **spritesGetSprite**
> SpritesGetSprite200Response spritesGetSprite(path)

Get a sprite JSON/PNG

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();
final JsonObject path = ; // JsonObject | 

try {
    final response = api.spritesGetSprite(path);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->spritesGetSprite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | [**JsonObject**](.md)|  | 

### Return type

[**SpritesGetSprite200Response**](SpritesGetSprite200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stylesGetDarkStyle**
> BuiltMap<String, JsonObject> stylesGetDarkStyle(key, mobile)

Get dark style

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();
final JsonObject key = ; // JsonObject | 
final JsonObject mobile = ; // JsonObject | 

try {
    final response = api.stylesGetDarkStyle(key, mobile);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->stylesGetDarkStyle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | [**JsonObject**](.md)|  | 
 **mobile** | [**JsonObject**](.md)|  | [optional] [default to false]

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stylesGetLightStyle**
> BuiltMap<String, JsonObject> stylesGetLightStyle(key, mobile)

Get light style

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getDefaultApi();
final String key = key_example; // String | 
final JsonObject mobile = ; // JsonObject | 

try {
    final response = api.stylesGetLightStyle(key, mobile);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->stylesGetLightStyle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **mobile** | [**JsonObject**](.md)|  | [optional] [default to false]

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

