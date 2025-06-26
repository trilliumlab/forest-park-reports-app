# traileyes_api.api.StylesApi

## Load the API package
```dart
import 'package:traileyes_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**stylesDarkJsonGet**](StylesApi.md#stylesdarkjsonget) | **GET** /styles/dark.json | Get dark style
[**stylesLightJsonGet**](StylesApi.md#styleslightjsonget) | **GET** /styles/light.json | Get light style


# **stylesDarkJsonGet**
> BuiltMap<String, JsonObject> stylesDarkJsonGet(key, mobile)

Get dark style

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getStylesApi();
final String key = key_example; // String | 
final bool mobile = true; // bool | 

try {
    final response = api.stylesDarkJsonGet(key, mobile);
    print(response);
} catch on DioException (e) {
    print('Exception when calling StylesApi->stylesDarkJsonGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **mobile** | **bool**|  | [optional] [default to false]

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stylesLightJsonGet**
> BuiltMap<String, JsonObject> stylesLightJsonGet(key, mobile)

Get light style

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getStylesApi();
final String key = key_example; // String | 
final bool mobile = true; // bool | 

try {
    final response = api.stylesLightJsonGet(key, mobile);
    print(response);
} catch on DioException (e) {
    print('Exception when calling StylesApi->stylesLightJsonGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **mobile** | **bool**|  | [optional] [default to false]

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

