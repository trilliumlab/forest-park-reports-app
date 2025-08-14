//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sprites_get_sprite200_response_value.g.dart';

/// SpritesGetSprite200ResponseValue
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
abstract class SpritesGetSprite200ResponseValue
    implements
        Built<SpritesGetSprite200ResponseValue,
            SpritesGetSprite200ResponseValueBuilder> {
  @BuiltValueField(wireName: r'height')
  num get height;

  @BuiltValueField(wireName: r'width')
  num get width;

  @BuiltValueField(wireName: r'x')
  num get x;

  @BuiltValueField(wireName: r'y')
  num get y;

  @BuiltValueField(wireName: r'pixelRatio')
  num get pixelRatio;

  @BuiltValueField(wireName: r'content')
  BuiltList<JsonObject?>? get content;

  @BuiltValueField(wireName: r'stretchX')
  BuiltList<BuiltList<JsonObject?>>? get stretchX;

  @BuiltValueField(wireName: r'stretchY')
  BuiltList<BuiltList<JsonObject?>>? get stretchY;

  @BuiltValueField(wireName: r'sdf')
  bool? get sdf;

  @BuiltValueField(wireName: r'textFitWidth')
  SpritesGetSprite200ResponseValueTextFitWidthEnum? get textFitWidth;
  // enum textFitWidthEnum {  stretchOrShrink,  stretchOnly,  proportional,  };

  @BuiltValueField(wireName: r'textFitHeight')
  SpritesGetSprite200ResponseValueTextFitHeightEnum? get textFitHeight;
  // enum textFitHeightEnum {  stretchOrShrink,  stretchOnly,  proportional,  };

  SpritesGetSprite200ResponseValue._();

  factory SpritesGetSprite200ResponseValue(
          [void updates(SpritesGetSprite200ResponseValueBuilder b)]) =
      _$SpritesGetSprite200ResponseValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpritesGetSprite200ResponseValueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpritesGetSprite200ResponseValue> get serializer =>
      _$SpritesGetSprite200ResponseValueSerializer();
}

class _$SpritesGetSprite200ResponseValueSerializer
    implements PrimitiveSerializer<SpritesGetSprite200ResponseValue> {
  @override
  final Iterable<Type> types = const [
    SpritesGetSprite200ResponseValue,
    _$SpritesGetSprite200ResponseValue
  ];

  @override
  final String wireName = r'SpritesGetSprite200ResponseValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpritesGetSprite200ResponseValue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'height';
    yield serializers.serialize(
      object.height,
      specifiedType: const FullType(num),
    );
    yield r'width';
    yield serializers.serialize(
      object.width,
      specifiedType: const FullType(num),
    );
    yield r'x';
    yield serializers.serialize(
      object.x,
      specifiedType: const FullType(num),
    );
    yield r'y';
    yield serializers.serialize(
      object.y,
      specifiedType: const FullType(num),
    );
    yield r'pixelRatio';
    yield serializers.serialize(
      object.pixelRatio,
      specifiedType: const FullType(num),
    );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType:
            const FullType(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
    if (object.stretchX != null) {
      yield r'stretchX';
      yield serializers.serialize(
        object.stretchX,
        specifiedType: const FullType(BuiltList, [
          FullType(BuiltList, [FullType.nullable(JsonObject)])
        ]),
      );
    }
    if (object.stretchY != null) {
      yield r'stretchY';
      yield serializers.serialize(
        object.stretchY,
        specifiedType: const FullType(BuiltList, [
          FullType(BuiltList, [FullType.nullable(JsonObject)])
        ]),
      );
    }
    if (object.sdf != null) {
      yield r'sdf';
      yield serializers.serialize(
        object.sdf,
        specifiedType: const FullType(bool),
      );
    }
    if (object.textFitWidth != null) {
      yield r'textFitWidth';
      yield serializers.serialize(
        object.textFitWidth,
        specifiedType:
            const FullType(SpritesGetSprite200ResponseValueTextFitWidthEnum),
      );
    }
    if (object.textFitHeight != null) {
      yield r'textFitHeight';
      yield serializers.serialize(
        object.textFitHeight,
        specifiedType:
            const FullType(SpritesGetSprite200ResponseValueTextFitHeightEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SpritesGetSprite200ResponseValue object, {
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
    required SpritesGetSprite200ResponseValueBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.height = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.width = valueDes;
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.x = valueDes;
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.y = valueDes;
          break;
        case r'pixelRatio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.pixelRatio = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>;
          result.content.replace(valueDes);
          break;
        case r'stretchX':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(BuiltList, [FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltList<JsonObject?>>;
          result.stretchX.replace(valueDes);
          break;
        case r'stretchY':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(BuiltList, [FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltList<JsonObject?>>;
          result.stretchY.replace(valueDes);
          break;
        case r'sdf':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sdf = valueDes;
          break;
        case r'textFitWidth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                SpritesGetSprite200ResponseValueTextFitWidthEnum),
          ) as SpritesGetSprite200ResponseValueTextFitWidthEnum;
          result.textFitWidth = valueDes;
          break;
        case r'textFitHeight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                SpritesGetSprite200ResponseValueTextFitHeightEnum),
          ) as SpritesGetSprite200ResponseValueTextFitHeightEnum;
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
  SpritesGetSprite200ResponseValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpritesGetSprite200ResponseValueBuilder();
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

class SpritesGetSprite200ResponseValueTextFitWidthEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stretchOrShrink')
  static const SpritesGetSprite200ResponseValueTextFitWidthEnum
      stretchOrShrink =
      _$spritesGetSprite200ResponseValueTextFitWidthEnum_stretchOrShrink;
  @BuiltValueEnumConst(wireName: r'stretchOnly')
  static const SpritesGetSprite200ResponseValueTextFitWidthEnum stretchOnly =
      _$spritesGetSprite200ResponseValueTextFitWidthEnum_stretchOnly;
  @BuiltValueEnumConst(wireName: r'proportional')
  static const SpritesGetSprite200ResponseValueTextFitWidthEnum proportional =
      _$spritesGetSprite200ResponseValueTextFitWidthEnum_proportional;

  static Serializer<SpritesGetSprite200ResponseValueTextFitWidthEnum>
      get serializer =>
          _$spritesGetSprite200ResponseValueTextFitWidthEnumSerializer;

  const SpritesGetSprite200ResponseValueTextFitWidthEnum._(String name)
      : super(name);

  static BuiltSet<SpritesGetSprite200ResponseValueTextFitWidthEnum>
      get values => _$spritesGetSprite200ResponseValueTextFitWidthEnumValues;
  static SpritesGetSprite200ResponseValueTextFitWidthEnum valueOf(
          String name) =>
      _$spritesGetSprite200ResponseValueTextFitWidthEnumValueOf(name);
}

class SpritesGetSprite200ResponseValueTextFitHeightEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stretchOrShrink')
  static const SpritesGetSprite200ResponseValueTextFitHeightEnum
      stretchOrShrink =
      _$spritesGetSprite200ResponseValueTextFitHeightEnum_stretchOrShrink;
  @BuiltValueEnumConst(wireName: r'stretchOnly')
  static const SpritesGetSprite200ResponseValueTextFitHeightEnum stretchOnly =
      _$spritesGetSprite200ResponseValueTextFitHeightEnum_stretchOnly;
  @BuiltValueEnumConst(wireName: r'proportional')
  static const SpritesGetSprite200ResponseValueTextFitHeightEnum proportional =
      _$spritesGetSprite200ResponseValueTextFitHeightEnum_proportional;

  static Serializer<SpritesGetSprite200ResponseValueTextFitHeightEnum>
      get serializer =>
          _$spritesGetSprite200ResponseValueTextFitHeightEnumSerializer;

  const SpritesGetSprite200ResponseValueTextFitHeightEnum._(String name)
      : super(name);

  static BuiltSet<SpritesGetSprite200ResponseValueTextFitHeightEnum>
      get values => _$spritesGetSprite200ResponseValueTextFitHeightEnumValues;
  static SpritesGetSprite200ResponseValueTextFitHeightEnum valueOf(
          String name) =>
      _$spritesGetSprite200ResponseValueTextFitHeightEnumValueOf(name);
}
