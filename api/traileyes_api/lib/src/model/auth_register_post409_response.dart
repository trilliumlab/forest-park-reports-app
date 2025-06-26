//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_register_post409_response.g.dart';

/// AuthRegisterPost409Response
///
/// Properties:
/// * [statusCode]
/// * [message]
/// * [error]
/// * [code]
@BuiltValue()
abstract class AuthRegisterPost409Response
    implements
        Built<AuthRegisterPost409Response, AuthRegisterPost409ResponseBuilder> {
  @BuiltValueField(wireName: r'statusCode')
  AuthRegisterPost409ResponseStatusCodeEnum get statusCode;
  // enum statusCodeEnum {  409,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'error')
  AuthRegisterPost409ResponseErrorEnum get error;
  // enum errorEnum {  Conflict,  };

  @BuiltValueField(wireName: r'code')
  AuthRegisterPost409ResponseCodeEnum get code;
  // enum codeEnum {  REGISTRATION_CONFLICT,  };

  AuthRegisterPost409Response._();

  factory AuthRegisterPost409Response(
          [void updates(AuthRegisterPost409ResponseBuilder b)]) =
      _$AuthRegisterPost409Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRegisterPost409ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRegisterPost409Response> get serializer =>
      _$AuthRegisterPost409ResponseSerializer();
}

class _$AuthRegisterPost409ResponseSerializer
    implements PrimitiveSerializer<AuthRegisterPost409Response> {
  @override
  final Iterable<Type> types = const [
    AuthRegisterPost409Response,
    _$AuthRegisterPost409Response
  ];

  @override
  final String wireName = r'AuthRegisterPost409Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRegisterPost409Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'statusCode';
    yield serializers.serialize(
      object.statusCode,
      specifiedType: const FullType(AuthRegisterPost409ResponseStatusCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(AuthRegisterPost409ResponseErrorEnum),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(AuthRegisterPost409ResponseCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRegisterPost409Response object, {
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
    required AuthRegisterPost409ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'statusCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(AuthRegisterPost409ResponseStatusCodeEnum),
          ) as AuthRegisterPost409ResponseStatusCodeEnum;
          result.statusCode = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthRegisterPost409ResponseErrorEnum),
          ) as AuthRegisterPost409ResponseErrorEnum;
          result.error = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthRegisterPost409ResponseCodeEnum),
          ) as AuthRegisterPost409ResponseCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthRegisterPost409Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRegisterPost409ResponseBuilder();
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

class AuthRegisterPost409ResponseStatusCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'409', fallback: true)
  static const AuthRegisterPost409ResponseStatusCodeEnum n409 =
      _$authRegisterPost409ResponseStatusCodeEnum_n409;

  static Serializer<AuthRegisterPost409ResponseStatusCodeEnum> get serializer =>
      _$authRegisterPost409ResponseStatusCodeEnumSerializer;

  const AuthRegisterPost409ResponseStatusCodeEnum._(String name) : super(name);

  static BuiltSet<AuthRegisterPost409ResponseStatusCodeEnum> get values =>
      _$authRegisterPost409ResponseStatusCodeEnumValues;
  static AuthRegisterPost409ResponseStatusCodeEnum valueOf(String name) =>
      _$authRegisterPost409ResponseStatusCodeEnumValueOf(name);
}

class AuthRegisterPost409ResponseErrorEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Conflict', fallback: true)
  static const AuthRegisterPost409ResponseErrorEnum conflict =
      _$authRegisterPost409ResponseErrorEnum_conflict;

  static Serializer<AuthRegisterPost409ResponseErrorEnum> get serializer =>
      _$authRegisterPost409ResponseErrorEnumSerializer;

  const AuthRegisterPost409ResponseErrorEnum._(String name) : super(name);

  static BuiltSet<AuthRegisterPost409ResponseErrorEnum> get values =>
      _$authRegisterPost409ResponseErrorEnumValues;
  static AuthRegisterPost409ResponseErrorEnum valueOf(String name) =>
      _$authRegisterPost409ResponseErrorEnumValueOf(name);
}

class AuthRegisterPost409ResponseCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'REGISTRATION_CONFLICT', fallback: true)
  static const AuthRegisterPost409ResponseCodeEnum REGISTRATION_CONFLICT =
      _$authRegisterPost409ResponseCodeEnum_REGISTRATION_CONFLICT;

  static Serializer<AuthRegisterPost409ResponseCodeEnum> get serializer =>
      _$authRegisterPost409ResponseCodeEnumSerializer;

  const AuthRegisterPost409ResponseCodeEnum._(String name) : super(name);

  static BuiltSet<AuthRegisterPost409ResponseCodeEnum> get values =>
      _$authRegisterPost409ResponseCodeEnumValues;
  static AuthRegisterPost409ResponseCodeEnum valueOf(String name) =>
      _$authRegisterPost409ResponseCodeEnumValueOf(name);
}
