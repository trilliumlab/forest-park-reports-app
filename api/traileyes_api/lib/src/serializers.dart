//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:traileyes_api/src/date_serializer.dart';
import 'package:traileyes_api/src/model/date.dart';

import 'package:traileyes_api/src/model/auth_get_verification_meta_get200_response.dart';
import 'package:traileyes_api/src/model/auth_get_verification_meta_get200_response_one_of.dart';
import 'package:traileyes_api/src/model/auth_get_verification_meta_get200_response_one_of1.dart';
import 'package:traileyes_api/src/model/auth_login_post200_response.dart';
import 'package:traileyes_api/src/model/auth_login_post401_response.dart';
import 'package:traileyes_api/src/model/auth_login_post_request.dart';
import 'package:traileyes_api/src/model/auth_register_post409_response.dart';
import 'package:traileyes_api/src/model/auth_register_post_request.dart';
import 'package:traileyes_api/src/model/auth_session_meta_get200_response.dart';
import 'package:traileyes_api/src/model/auth_session_meta_get401_response.dart';
import 'package:traileyes_api/src/model/auth_session_meta_get500_response.dart';
import 'package:traileyes_api/src/model/auth_verify_email_post401_response.dart';
import 'package:traileyes_api/src/model/auth_verify_email_post_request.dart';
import 'package:traileyes_api/src/model/sprites_path_json_get200_response_value.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthGetVerificationMetaGet200Response,
  AuthGetVerificationMetaGet200ResponseOneOf,
  AuthGetVerificationMetaGet200ResponseOneOf1,
  AuthLoginPost200Response,
  AuthLoginPost401Response,
  AuthLoginPostRequest,
  AuthRegisterPost409Response,
  AuthRegisterPostRequest,
  AuthSessionMetaGet200Response,
  AuthSessionMetaGet401Response,
  AuthSessionMetaGet500Response,
  AuthVerifyEmailPost401Response,
  AuthVerifyEmailPostRequest,
  SpritesPathJsonGet200ResponseValue,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap,
            [FullType(String), FullType(SpritesPathJsonGet200ResponseValue)]),
        () => MapBuilder<String, SpritesPathJsonGet200ResponseValue>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(JsonObject)]),
        () => MapBuilder<String, JsonObject>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
