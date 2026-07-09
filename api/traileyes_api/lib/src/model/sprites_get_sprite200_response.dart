//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:traileyes_api/src/model/sprites_get_sprite200_response_any_of_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'sprites_get_sprite200_response.g.dart';

/// SpritesGetSprite200Response
@BuiltValue()
abstract class SpritesGetSprite200Response
    implements
        Built<SpritesGetSprite200Response, SpritesGetSprite200ResponseBuilder> {
  /// Any Of [BuiltMap<String, SpritesGetSprite200ResponseAnyOfValue>], [JsonObject]
  AnyOf get anyOf;

  SpritesGetSprite200Response._();

  factory SpritesGetSprite200Response(
          [void updates(SpritesGetSprite200ResponseBuilder b)]) =
      _$SpritesGetSprite200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpritesGetSprite200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpritesGetSprite200Response> get serializer =>
      _$SpritesGetSprite200ResponseSerializer();
}

class _$SpritesGetSprite200ResponseSerializer
    implements PrimitiveSerializer<SpritesGetSprite200Response> {
  @override
  final Iterable<Type> types = const [
    SpritesGetSprite200Response,
    _$SpritesGetSprite200Response
  ];

  @override
  final String wireName = r'SpritesGetSprite200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpritesGetSprite200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    SpritesGetSprite200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  SpritesGetSprite200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpritesGetSprite200ResponseBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType.nullable(
          BuiltMap, [FullType(SpritesGetSprite200ResponseAnyOfValue)]),
      FullType.nullable(JsonObject),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
