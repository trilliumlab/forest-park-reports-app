//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_session_meta_get401_response.g.dart';

/// AuthSessionMetaGet401Response
///
/// Properties:
/// * [statusCode]
/// * [message]
/// * [error]
/// * [code]
@BuiltValue()
abstract class AuthSessionMetaGet401Response
    implements
        Built<AuthSessionMetaGet401Response,
            AuthSessionMetaGet401ResponseBuilder> {
  @BuiltValueField(wireName: r'statusCode')
  AuthSessionMetaGet401ResponseStatusCodeEnum get statusCode;
  // enum statusCodeEnum {  401,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'error')
  AuthSessionMetaGet401ResponseErrorEnum get error;
  // enum errorEnum {  Unauthorized,  };

  @BuiltValueField(wireName: r'code')
  AuthSessionMetaGet401ResponseCodeEnum get code;
  // enum codeEnum {  INVALID_SESSION,  };

  AuthSessionMetaGet401Response._();

  factory AuthSessionMetaGet401Response(
          [void updates(AuthSessionMetaGet401ResponseBuilder b)]) =
      _$AuthSessionMetaGet401Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthSessionMetaGet401ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthSessionMetaGet401Response> get serializer =>
      _$AuthSessionMetaGet401ResponseSerializer();
}

class _$AuthSessionMetaGet401ResponseSerializer
    implements PrimitiveSerializer<AuthSessionMetaGet401Response> {
  @override
  final Iterable<Type> types = const [
    AuthSessionMetaGet401Response,
    _$AuthSessionMetaGet401Response
  ];

  @override
  final String wireName = r'AuthSessionMetaGet401Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthSessionMetaGet401Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'statusCode';
    yield serializers.serialize(
      object.statusCode,
      specifiedType:
          const FullType(AuthSessionMetaGet401ResponseStatusCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(AuthSessionMetaGet401ResponseErrorEnum),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(AuthSessionMetaGet401ResponseCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthSessionMetaGet401Response object, {
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
    required AuthSessionMetaGet401ResponseBuilder result,
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
                const FullType(AuthSessionMetaGet401ResponseStatusCodeEnum),
          ) as AuthSessionMetaGet401ResponseStatusCodeEnum;
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
            specifiedType:
                const FullType(AuthSessionMetaGet401ResponseErrorEnum),
          ) as AuthSessionMetaGet401ResponseErrorEnum;
          result.error = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(AuthSessionMetaGet401ResponseCodeEnum),
          ) as AuthSessionMetaGet401ResponseCodeEnum;
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
  AuthSessionMetaGet401Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthSessionMetaGet401ResponseBuilder();
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

class AuthSessionMetaGet401ResponseStatusCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'401', fallback: true)
  static const AuthSessionMetaGet401ResponseStatusCodeEnum n401 =
      _$authSessionMetaGet401ResponseStatusCodeEnum_n401;

  static Serializer<AuthSessionMetaGet401ResponseStatusCodeEnum>
      get serializer => _$authSessionMetaGet401ResponseStatusCodeEnumSerializer;

  const AuthSessionMetaGet401ResponseStatusCodeEnum._(String name)
      : super(name);

  static BuiltSet<AuthSessionMetaGet401ResponseStatusCodeEnum> get values =>
      _$authSessionMetaGet401ResponseStatusCodeEnumValues;
  static AuthSessionMetaGet401ResponseStatusCodeEnum valueOf(String name) =>
      _$authSessionMetaGet401ResponseStatusCodeEnumValueOf(name);
}

class AuthSessionMetaGet401ResponseErrorEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Unauthorized', fallback: true)
  static const AuthSessionMetaGet401ResponseErrorEnum unauthorized =
      _$authSessionMetaGet401ResponseErrorEnum_unauthorized;

  static Serializer<AuthSessionMetaGet401ResponseErrorEnum> get serializer =>
      _$authSessionMetaGet401ResponseErrorEnumSerializer;

  const AuthSessionMetaGet401ResponseErrorEnum._(String name) : super(name);

  static BuiltSet<AuthSessionMetaGet401ResponseErrorEnum> get values =>
      _$authSessionMetaGet401ResponseErrorEnumValues;
  static AuthSessionMetaGet401ResponseErrorEnum valueOf(String name) =>
      _$authSessionMetaGet401ResponseErrorEnumValueOf(name);
}

class AuthSessionMetaGet401ResponseCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'INVALID_SESSION', fallback: true)
  static const AuthSessionMetaGet401ResponseCodeEnum INVALID_SESSION =
      _$authSessionMetaGet401ResponseCodeEnum_INVALID_SESSION;

  static Serializer<AuthSessionMetaGet401ResponseCodeEnum> get serializer =>
      _$authSessionMetaGet401ResponseCodeEnumSerializer;

  const AuthSessionMetaGet401ResponseCodeEnum._(String name) : super(name);

  static BuiltSet<AuthSessionMetaGet401ResponseCodeEnum> get values =>
      _$authSessionMetaGet401ResponseCodeEnumValues;
  static AuthSessionMetaGet401ResponseCodeEnum valueOf(String name) =>
      _$authSessionMetaGet401ResponseCodeEnumValueOf(name);
}
