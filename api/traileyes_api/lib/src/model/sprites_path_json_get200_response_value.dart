//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sprites_path_json_get200_response_value.g.dart';

/// SpritesPathJsonGet200ResponseValue
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
abstract class SpritesPathJsonGet200ResponseValue
    implements
        Built<SpritesPathJsonGet200ResponseValue,
            SpritesPathJsonGet200ResponseValueBuilder> {
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
  JsonObject? get content;

  @BuiltValueField(wireName: r'stretchX')
  BuiltList<JsonObject?>? get stretchX;

  @BuiltValueField(wireName: r'stretchY')
  BuiltList<JsonObject?>? get stretchY;

  @BuiltValueField(wireName: r'sdf')
  bool? get sdf;

  @BuiltValueField(wireName: r'textFitWidth')
  SpritesPathJsonGet200ResponseValueTextFitWidthEnum? get textFitWidth;
  // enum textFitWidthEnum {  stretchOrShrink,  stretchOnly,  proportional,  };

  @BuiltValueField(wireName: r'textFitHeight')
  SpritesPathJsonGet200ResponseValueTextFitHeightEnum? get textFitHeight;
  // enum textFitHeightEnum {  stretchOrShrink,  stretchOnly,  proportional,  };

  SpritesPathJsonGet200ResponseValue._();

  factory SpritesPathJsonGet200ResponseValue(
          [void updates(SpritesPathJsonGet200ResponseValueBuilder b)]) =
      _$SpritesPathJsonGet200ResponseValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpritesPathJsonGet200ResponseValueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpritesPathJsonGet200ResponseValue> get serializer =>
      _$SpritesPathJsonGet200ResponseValueSerializer();
}

class _$SpritesPathJsonGet200ResponseValueSerializer
    implements PrimitiveSerializer<SpritesPathJsonGet200ResponseValue> {
  @override
  final Iterable<Type> types = const [
    SpritesPathJsonGet200ResponseValue,
    _$SpritesPathJsonGet200ResponseValue
  ];

  @override
  final String wireName = r'SpritesPathJsonGet200ResponseValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpritesPathJsonGet200ResponseValue object, {
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
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.stretchX != null) {
      yield r'stretchX';
      yield serializers.serialize(
        object.stretchX,
        specifiedType:
            const FullType(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
    if (object.stretchY != null) {
      yield r'stretchY';
      yield serializers.serialize(
        object.stretchY,
        specifiedType:
            const FullType(BuiltList, [FullType.nullable(JsonObject)]),
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
            const FullType(SpritesPathJsonGet200ResponseValueTextFitWidthEnum),
      );
    }
    if (object.textFitHeight != null) {
      yield r'textFitHeight';
      yield serializers.serialize(
        object.textFitHeight,
        specifiedType:
            const FullType(SpritesPathJsonGet200ResponseValueTextFitHeightEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SpritesPathJsonGet200ResponseValue object, {
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
    required SpritesPathJsonGet200ResponseValueBuilder result,
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
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        case r'stretchX':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>;
          result.stretchX.replace(valueDes);
          break;
        case r'stretchY':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>;
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
                SpritesPathJsonGet200ResponseValueTextFitWidthEnum),
          ) as SpritesPathJsonGet200ResponseValueTextFitWidthEnum;
          result.textFitWidth = valueDes;
          break;
        case r'textFitHeight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                SpritesPathJsonGet200ResponseValueTextFitHeightEnum),
          ) as SpritesPathJsonGet200ResponseValueTextFitHeightEnum;
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
  SpritesPathJsonGet200ResponseValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpritesPathJsonGet200ResponseValueBuilder();
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

class SpritesPathJsonGet200ResponseValueTextFitWidthEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stretchOrShrink')
  static const SpritesPathJsonGet200ResponseValueTextFitWidthEnum
      stretchOrShrink =
      _$spritesPathJsonGet200ResponseValueTextFitWidthEnum_stretchOrShrink;
  @BuiltValueEnumConst(wireName: r'stretchOnly')
  static const SpritesPathJsonGet200ResponseValueTextFitWidthEnum stretchOnly =
      _$spritesPathJsonGet200ResponseValueTextFitWidthEnum_stretchOnly;
  @BuiltValueEnumConst(wireName: r'proportional', fallback: true)
  static const SpritesPathJsonGet200ResponseValueTextFitWidthEnum proportional =
      _$spritesPathJsonGet200ResponseValueTextFitWidthEnum_proportional;

  static Serializer<SpritesPathJsonGet200ResponseValueTextFitWidthEnum>
      get serializer =>
          _$spritesPathJsonGet200ResponseValueTextFitWidthEnumSerializer;

  const SpritesPathJsonGet200ResponseValueTextFitWidthEnum._(String name)
      : super(name);

  static BuiltSet<SpritesPathJsonGet200ResponseValueTextFitWidthEnum>
      get values => _$spritesPathJsonGet200ResponseValueTextFitWidthEnumValues;
  static SpritesPathJsonGet200ResponseValueTextFitWidthEnum valueOf(
          String name) =>
      _$spritesPathJsonGet200ResponseValueTextFitWidthEnumValueOf(name);
}

class SpritesPathJsonGet200ResponseValueTextFitHeightEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stretchOrShrink')
  static const SpritesPathJsonGet200ResponseValueTextFitHeightEnum
      stretchOrShrink =
      _$spritesPathJsonGet200ResponseValueTextFitHeightEnum_stretchOrShrink;
  @BuiltValueEnumConst(wireName: r'stretchOnly')
  static const SpritesPathJsonGet200ResponseValueTextFitHeightEnum stretchOnly =
      _$spritesPathJsonGet200ResponseValueTextFitHeightEnum_stretchOnly;
  @BuiltValueEnumConst(wireName: r'proportional', fallback: true)
  static const SpritesPathJsonGet200ResponseValueTextFitHeightEnum
      proportional =
      _$spritesPathJsonGet200ResponseValueTextFitHeightEnum_proportional;

  static Serializer<SpritesPathJsonGet200ResponseValueTextFitHeightEnum>
      get serializer =>
          _$spritesPathJsonGet200ResponseValueTextFitHeightEnumSerializer;

  const SpritesPathJsonGet200ResponseValueTextFitHeightEnum._(String name)
      : super(name);

  static BuiltSet<SpritesPathJsonGet200ResponseValueTextFitHeightEnum>
      get values => _$spritesPathJsonGet200ResponseValueTextFitHeightEnumValues;
  static SpritesPathJsonGet200ResponseValueTextFitHeightEnum valueOf(
          String name) =>
      _$spritesPathJsonGet200ResponseValueTextFitHeightEnumValueOf(name);
}
