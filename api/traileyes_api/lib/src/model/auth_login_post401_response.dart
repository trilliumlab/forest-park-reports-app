//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login_post401_response.g.dart';

/// AuthLoginPost401Response
///
/// Properties:
/// * [statusCode]
/// * [message]
/// * [error]
/// * [code]
@BuiltValue()
abstract class AuthLoginPost401Response
    implements
        Built<AuthLoginPost401Response, AuthLoginPost401ResponseBuilder> {
  @BuiltValueField(wireName: r'statusCode')
  AuthLoginPost401ResponseStatusCodeEnum get statusCode;
  // enum statusCodeEnum {  401,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'error')
  AuthLoginPost401ResponseErrorEnum get error;
  // enum errorEnum {  Unauthorized,  };

  @BuiltValueField(wireName: r'code')
  AuthLoginPost401ResponseCodeEnum get code;
  // enum codeEnum {  INVALID_CREDENTIALS,  };

  AuthLoginPost401Response._();

  factory AuthLoginPost401Response(
          [void updates(AuthLoginPost401ResponseBuilder b)]) =
      _$AuthLoginPost401Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLoginPost401ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLoginPost401Response> get serializer =>
      _$AuthLoginPost401ResponseSerializer();
}

class _$AuthLoginPost401ResponseSerializer
    implements PrimitiveSerializer<AuthLoginPost401Response> {
  @override
  final Iterable<Type> types = const [
    AuthLoginPost401Response,
    _$AuthLoginPost401Response
  ];

  @override
  final String wireName = r'AuthLoginPost401Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLoginPost401Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'statusCode';
    yield serializers.serialize(
      object.statusCode,
      specifiedType: const FullType(AuthLoginPost401ResponseStatusCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(AuthLoginPost401ResponseErrorEnum),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(AuthLoginPost401ResponseCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLoginPost401Response object, {
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
    required AuthLoginPost401ResponseBuilder result,
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
                const FullType(AuthLoginPost401ResponseStatusCodeEnum),
          ) as AuthLoginPost401ResponseStatusCodeEnum;
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
            specifiedType: const FullType(AuthLoginPost401ResponseErrorEnum),
          ) as AuthLoginPost401ResponseErrorEnum;
          result.error = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthLoginPost401ResponseCodeEnum),
          ) as AuthLoginPost401ResponseCodeEnum;
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
  AuthLoginPost401Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLoginPost401ResponseBuilder();
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

class AuthLoginPost401ResponseStatusCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'401', fallback: true)
  static const AuthLoginPost401ResponseStatusCodeEnum n401 =
      _$authLoginPost401ResponseStatusCodeEnum_n401;

  static Serializer<AuthLoginPost401ResponseStatusCodeEnum> get serializer =>
      _$authLoginPost401ResponseStatusCodeEnumSerializer;

  const AuthLoginPost401ResponseStatusCodeEnum._(String name) : super(name);

  static BuiltSet<AuthLoginPost401ResponseStatusCodeEnum> get values =>
      _$authLoginPost401ResponseStatusCodeEnumValues;
  static AuthLoginPost401ResponseStatusCodeEnum valueOf(String name) =>
      _$authLoginPost401ResponseStatusCodeEnumValueOf(name);
}

class AuthLoginPost401ResponseErrorEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Unauthorized', fallback: true)
  static const AuthLoginPost401ResponseErrorEnum unauthorized =
      _$authLoginPost401ResponseErrorEnum_unauthorized;

  static Serializer<AuthLoginPost401ResponseErrorEnum> get serializer =>
      _$authLoginPost401ResponseErrorEnumSerializer;

  const AuthLoginPost401ResponseErrorEnum._(String name) : super(name);

  static BuiltSet<AuthLoginPost401ResponseErrorEnum> get values =>
      _$authLoginPost401ResponseErrorEnumValues;
  static AuthLoginPost401ResponseErrorEnum valueOf(String name) =>
      _$authLoginPost401ResponseErrorEnumValueOf(name);
}

class AuthLoginPost401ResponseCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'INVALID_CREDENTIALS', fallback: true)
  static const AuthLoginPost401ResponseCodeEnum INVALID_CREDENTIALS =
      _$authLoginPost401ResponseCodeEnum_INVALID_CREDENTIALS;

  static Serializer<AuthLoginPost401ResponseCodeEnum> get serializer =>
      _$authLoginPost401ResponseCodeEnumSerializer;

  const AuthLoginPost401ResponseCodeEnum._(String name) : super(name);

  static BuiltSet<AuthLoginPost401ResponseCodeEnum> get values =>
      _$authLoginPost401ResponseCodeEnumValues;
  static AuthLoginPost401ResponseCodeEnum valueOf(String name) =>
      _$authLoginPost401ResponseCodeEnumValueOf(name);
}
