//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sprites_get_sprite200_response_any_of_value.g.dart';

/// SpritesGetSprite200ResponseAnyOfValue
///
/// Properties:
/// * [height]
/// * [width]
/// * [x]
/// * [y]
/// * [pixelRatio]
/// * [content]
/// * [stretchX]
/// * [stretchY]
/// * [sdf]
/// * [textFitWidth]
/// * [textFitHeight]
@BuiltValue()
abstract class SpritesGetSprite200ResponseAnyOfValue
    implements
        Built<SpritesGetSprite200ResponseAnyOfValue,
            SpritesGetSprite200ResponseAnyOfValueBuilder> {
  @BuiltValueField(wireName: r'height')
  JsonObject? get height;

  @BuiltValueField(wireName: r'width')
  JsonObject? get width;

  @BuiltValueField(wireName: r'x')
  JsonObject? get x;

  @BuiltValueField(wireName: r'y')
  JsonObject? get y;

  @BuiltValueField(wireName: r'pixelRatio')
  JsonObject? get pixelRatio;

  @BuiltValueField(wireName: r'content')
  JsonObject? get content;

  @BuiltValueField(wireName: r'stretchX')
  JsonObject? get stretchX;

  @BuiltValueField(wireName: r'stretchY')
  JsonObject? get stretchY;

  @BuiltValueField(wireName: r'sdf')
  JsonObject? get sdf;

  @BuiltValueField(wireName: r'textFitWidth')
  SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum? get textFitWidth;
  // enum textFitWidthEnum {  stretchOrShrink,  stretchOnly,  proportional,  };

  @BuiltValueField(wireName: r'textFitHeight')
  SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum? get textFitHeight;
  // enum textFitHeightEnum {  stretchOrShrink,  stretchOnly,  proportional,  };

  SpritesGetSprite200ResponseAnyOfValue._();

  factory SpritesGetSprite200ResponseAnyOfValue(
          [void updates(SpritesGetSprite200ResponseAnyOfValueBuilder b)]) =
      _$SpritesGetSprite200ResponseAnyOfValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpritesGetSprite200ResponseAnyOfValueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpritesGetSprite200ResponseAnyOfValue> get serializer =>
      _$SpritesGetSprite200ResponseAnyOfValueSerializer();
}

class _$SpritesGetSprite200ResponseAnyOfValueSerializer
    implements PrimitiveSerializer<SpritesGetSprite200ResponseAnyOfValue> {
  @override
  final Iterable<Type> types = const [
    SpritesGetSprite200ResponseAnyOfValue,
    _$SpritesGetSprite200ResponseAnyOfValue
  ];

  @override
  final String wireName = r'SpritesGetSprite200ResponseAnyOfValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpritesGetSprite200ResponseAnyOfValue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'height';
    yield object.height == null
        ? null
        : serializers.serialize(
            object.height,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'width';
    yield object.width == null
        ? null
        : serializers.serialize(
            object.width,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'x';
    yield object.x == null
        ? null
        : serializers.serialize(
            object.x,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'y';
    yield object.y == null
        ? null
        : serializers.serialize(
            object.y,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'pixelRatio';
    yield object.pixelRatio == null
        ? null
        : serializers.serialize(
            object.pixelRatio,
            specifiedType: const FullType.nullable(JsonObject),
          );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.stretchX != null) {
      yield r'stretchX';
      yield serializers.serialize(
        object.stretchX,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.stretchY != null) {
      yield r'stretchY';
      yield serializers.serialize(
        object.stretchY,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.sdf != null) {
      yield r'sdf';
      yield serializers.serialize(
        object.sdf,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.textFitWidth != null) {
      yield r'textFitWidth';
      yield serializers.serialize(
        object.textFitWidth,
        specifiedType: const FullType.nullable(
            SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum),
      );
    }
    if (object.textFitHeight != null) {
      yield r'textFitHeight';
      yield serializers.serialize(
        object.textFitHeight,
        specifiedType: const FullType.nullable(
            SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SpritesGetSprite200ResponseAnyOfValue object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SpritesGetSprite200ResponseAnyOfValueBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.height = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.width = valueDes;
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.x = valueDes;
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.y = valueDes;
          break;
        case r'pixelRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.pixelRatio = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        case r'stretchX':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.stretchX = valueDes;
          break;
        case r'stretchY':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.stretchY = valueDes;
          break;
        case r'sdf':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.sdf = valueDes;
          break;
        case r'textFitWidth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum),
          ) as SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum?;
          if (valueDes == null) continue;
          result.textFitWidth = valueDes;
          break;
        case r'textFitHeight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum),
          ) as SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum?;
          if (valueDes == null) continue;
          result.textFitHeight = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SpritesGetSprite200ResponseAnyOfValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpritesGetSprite200ResponseAnyOfValueBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stretchOrShrink')
  static const SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum
      stretchOrShrink =
      _$spritesGetSprite200ResponseAnyOfValueTextFitWidthEnum_stretchOrShrink;
  @BuiltValueEnumConst(wireName: r'stretchOnly')
  static const SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum
      stretchOnly =
      _$spritesGetSprite200ResponseAnyOfValueTextFitWidthEnum_stretchOnly;
  @BuiltValueEnumConst(wireName: r'proportional', fallback: true)
  static const SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum
      proportional =
      _$spritesGetSprite200ResponseAnyOfValueTextFitWidthEnum_proportional;

  static Serializer<SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum>
      get serializer =>
          _$spritesGetSprite200ResponseAnyOfValueTextFitWidthEnumSerializer;

  const SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum._(String name)
      : super(name);

  static BuiltSet<SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum>
      get values =>
          _$spritesGetSprite200ResponseAnyOfValueTextFitWidthEnumValues;
  static SpritesGetSprite200ResponseAnyOfValueTextFitWidthEnum valueOf(
          String name) =>
      _$spritesGetSprite200ResponseAnyOfValueTextFitWidthEnumValueOf(name);
}

class SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stretchOrShrink')
  static const SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum
      stretchOrShrink =
      _$spritesGetSprite200ResponseAnyOfValueTextFitHeightEnum_stretchOrShrink;
  @BuiltValueEnumConst(wireName: r'stretchOnly')
  static const SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum
      stretchOnly =
      _$spritesGetSprite200ResponseAnyOfValueTextFitHeightEnum_stretchOnly;
  @BuiltValueEnumConst(wireName: r'proportional', fallback: true)
  static const SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum
      proportional =
      _$spritesGetSprite200ResponseAnyOfValueTextFitHeightEnum_proportional;

  static Serializer<SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum>
      get serializer =>
          _$spritesGetSprite200ResponseAnyOfValueTextFitHeightEnumSerializer;

  const SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum._(String name)
      : super(name);

  static BuiltSet<SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum>
      get values =>
          _$spritesGetSprite200ResponseAnyOfValueTextFitHeightEnumValues;
  static SpritesGetSprite200ResponseAnyOfValueTextFitHeightEnum valueOf(
          String name) =>
      _$spritesGetSprite200ResponseAnyOfValueTextFitHeightEnumValueOf(name);
}
