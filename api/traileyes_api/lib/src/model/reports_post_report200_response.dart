//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'reports_post_report200_response.g.dart';

/// ReportsPostReport200Response
@BuiltValue()
abstract class ReportsPostReport200Response
    implements
        Built<ReportsPostReport200Response,
            ReportsPostReport200ResponseBuilder> {
  /// Any Of [JsonObject]
  AnyOf get anyOf;

  ReportsPostReport200Response._();

  factory ReportsPostReport200Response(
          [void updates(ReportsPostReport200ResponseBuilder b)]) =
      _$ReportsPostReport200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsPostReport200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsPostReport200Response> get serializer =>
      _$ReportsPostReport200ResponseSerializer();
}

class _$ReportsPostReport200ResponseSerializer
    implements PrimitiveSerializer<ReportsPostReport200Response> {
  @override
  final Iterable<Type> types = const [
    ReportsPostReport200Response,
    _$ReportsPostReport200Response
  ];

  @override
  final String wireName = r'ReportsPostReport200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsPostReport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    ReportsPostReport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  ReportsPostReport200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsPostReport200ResponseBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType.nullable(JsonObject),
      FullType.nullable(JsonObject),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
