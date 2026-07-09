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

import 'package:traileyes_api/src/model/reports_post_report200_response.dart';
import 'package:traileyes_api/src/model/reports_post_report_request.dart';
import 'package:traileyes_api/src/model/reports_post_report_request_geometry.dart';
import 'package:traileyes_api/src/model/sprites_get_sprite200_response.dart';
import 'package:traileyes_api/src/model/sprites_get_sprite200_response_any_of_value.dart';

part 'serializers.g.dart';

@SerializersFor([
  ReportsPostReport200Response,
  ReportsPostReportRequest,
  ReportsPostReportRequestGeometry,
  SpritesGetSprite200Response,
  SpritesGetSprite200ResponseAnyOfValue,
])
Serializers serializers = (_$serializers.toBuilder()
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
