# traileyes_api.api.AuthApi

## Load the API package
```dart
import 'package:traileyes_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authEnabledSecondFactorsGet**](AuthApi.md#authenabledsecondfactorsget) | **GET** /auth/enabled-second-factors | Get enabled second factors
[**authGetVerificationMetaGet**](AuthApi.md#authgetverificationmetaget) | **GET** /auth/get-verification-meta | Get verification metadata
[**authLoginPost**](AuthApi.md#authloginpost) | **POST** /auth/login | Login a user
[**authRegisterPost**](AuthApi.md#authregisterpost) | **POST** /auth/register | Register a new user
[**authSendVerificationPost**](AuthApi.md#authsendverificationpost) | **POST** /auth/send-verification | Send verification email
[**authSessionMetaGet**](AuthApi.md#authsessionmetaget) | **GET** /auth/session-meta | Get session metadata
[**authVerifyEmailPost**](AuthApi.md#authverifyemailpost) | **POST** /auth/verify-email | Verify email


# **authEnabledSecondFactorsGet**
> BuiltList<String> authEnabledSecondFactorsGet()

Get enabled second factors

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();

try {
    final response = api.authEnabledSecondFactorsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authEnabledSecondFactorsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**BuiltList&lt;String&gt;**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authGetVerificationMetaGet**
> AuthGetVerificationMetaGet200Response authGetVerificationMetaGet()

Get verification metadata

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();

try {
    final response = api.authGetVerificationMetaGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authGetVerificationMetaGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthGetVerificationMetaGet200Response**](AuthGetVerificationMetaGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLoginPost**
> AuthLoginPost200Response authLoginPost(authLoginPostRequest)

Login a user

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();
final AuthLoginPostRequest authLoginPostRequest = ; // AuthLoginPostRequest | Body

try {
    final response = api.authLoginPost(authLoginPostRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authLoginPostRequest** | [**AuthLoginPostRequest**](AuthLoginPostRequest.md)| Body | [optional] 

### Return type

[**AuthLoginPost200Response**](AuthLoginPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegisterPost**
> authRegisterPost(authRegisterPostRequest)

Register a new user

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();
final AuthRegisterPostRequest authRegisterPostRequest = ; // AuthRegisterPostRequest | Body

try {
    api.authRegisterPost(authRegisterPostRequest);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRegisterPostRequest** | [**AuthRegisterPostRequest**](AuthRegisterPostRequest.md)| Body | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authSendVerificationPost**
> AuthGetVerificationMetaGet200Response authSendVerificationPost()

Send verification email

Sends a verification email to the user's email address. If a code has been sent in the last 90 seconds, no action is taken.

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();

try {
    final response = api.authSendVerificationPost();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authSendVerificationPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthGetVerificationMetaGet200Response**](AuthGetVerificationMetaGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authSessionMetaGet**
> AuthSessionMetaGet200Response authSessionMetaGet()

Get session metadata

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();

try {
    final response = api.authSessionMetaGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authSessionMetaGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthSessionMetaGet200Response**](AuthSessionMetaGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authVerifyEmailPost**
> authVerifyEmailPost(authVerifyEmailPostRequest)

Verify email

### Example
```dart
import 'package:traileyes_api/api.dart';

final api = TraileyesApi().getAuthApi();
final AuthVerifyEmailPostRequest authVerifyEmailPostRequest = ; // AuthVerifyEmailPostRequest | Body

try {
    api.authVerifyEmailPost(authVerifyEmailPostRequest);
} catch on DioException (e) {
    print('Exception when calling AuthApi->authVerifyEmailPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authVerifyEmailPostRequest** | [**AuthVerifyEmailPostRequest**](AuthVerifyEmailPostRequest.md)| Body | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

