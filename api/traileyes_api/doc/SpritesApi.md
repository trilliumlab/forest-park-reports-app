# traileyes_api.api.SpritesApi

## Load the API package
```dart
import 'package:traileyes_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**spritesPathJsonGet**](SpritesApi.md#spritespathjsonget) | **GET** /sprites/{path}.json | Get a sprite
[**spritesPathPngGet**](SpritesApi.md#spritespathpngget) | **GET** /sprites/{path}.png | Get a sprite


# **spritesPathJsonGet**
> BuiltMap<String, SpritesPathJsonGet200ResponseValue> spritesPathJsonGet(path)

Get a sprite

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getSpritesApi();
final String path = path_example; // String | 

try {
    final response = api.spritesPathJsonGet(path);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SpritesApi->spritesPathJsonGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | **String**|  | 

### Return type

[**BuiltMap&lt;String, SpritesPathJsonGet200ResponseValue&gt;**](SpritesPathJsonGet200ResponseValue.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **spritesPathPngGet**
> JsonObject spritesPathPngGet(path)

Get a sprite

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getSpritesApi();
final String path = path_example; // String | 

try {
    final response = api.spritesPathPngGet(path);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SpritesApi->spritesPathPngGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **path** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

