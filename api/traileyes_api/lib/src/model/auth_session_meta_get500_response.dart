//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_session_meta_get500_response.g.dart';

/// AuthSessionMetaGet500Response
///
/// Properties:
/// * [statusCode]
/// * [message]
/// * [error]
/// * [code]
@BuiltValue()
abstract class AuthSessionMetaGet500Response
    implements
        Built<AuthSessionMetaGet500Response,
            AuthSessionMetaGet500ResponseBuilder> {
  @BuiltValueField(wireName: r'statusCode')
  AuthSessionMetaGet500ResponseStatusCodeEnum get statusCode;
  // enum statusCodeEnum {  500,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'error')
  AuthSessionMetaGet500ResponseErrorEnum get error;
  // enum errorEnum {  Internal Server Error,  };

  @BuiltValueField(wireName: r'code')
  String? get code;

  AuthSessionMetaGet500Response._();

  factory AuthSessionMetaGet500Response(
          [void updates(AuthSessionMetaGet500ResponseBuilder b)]) =
      _$AuthSessionMetaGet500Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthSessionMetaGet500ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthSessionMetaGet500Response> get serializer =>
      _$AuthSessionMetaGet500ResponseSerializer();
}

class _$AuthSessionMetaGet500ResponseSerializer
    implements PrimitiveSerializer<AuthSessionMetaGet500Response> {
  @override
  final Iterable<Type> types = const [
    AuthSessionMetaGet500Response,
    _$AuthSessionMetaGet500Response
  ];

  @override
  final String wireName = r'AuthSessionMetaGet500Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthSessionMetaGet500Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'statusCode';
    yield serializers.serialize(
      object.statusCode,
      specifiedType:
          const FullType(AuthSessionMetaGet500ResponseStatusCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(AuthSessionMetaGet500ResponseErrorEnum),
    );
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthSessionMetaGet500Response object, {
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
    required AuthSessionMetaGet500ResponseBuilder result,
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
                const FullType(AuthSessionMetaGet500ResponseStatusCodeEnum),
          ) as AuthSessionMetaGet500ResponseStatusCodeEnum;
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
                const FullType(AuthSessionMetaGet500ResponseErrorEnum),
          ) as AuthSessionMetaGet500ResponseErrorEnum;
          result.error = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  AuthSessionMetaGet500Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthSessionMetaGet500ResponseBuilder();
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

class AuthSessionMetaGet500ResponseStatusCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'500', fallback: true)
  static const AuthSessionMetaGet500ResponseStatusCodeEnum n500 =
      _$authSessionMetaGet500ResponseStatusCodeEnum_n500;

  static Serializer<AuthSessionMetaGet500ResponseStatusCodeEnum>
      get serializer => _$authSessionMetaGet500ResponseStatusCodeEnumSerializer;

  const AuthSessionMetaGet500ResponseStatusCodeEnum._(String name)
      : super(name);

  static BuiltSet<AuthSessionMetaGet500ResponseStatusCodeEnum> get values =>
      _$authSessionMetaGet500ResponseStatusCodeEnumValues;
  static AuthSessionMetaGet500ResponseStatusCodeEnum valueOf(String name) =>
      _$authSessionMetaGet500ResponseStatusCodeEnumValueOf(name);
}

class AuthSessionMetaGet500ResponseErrorEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Internal Server Error', fallback: true)
  static const AuthSessionMetaGet500ResponseErrorEnum internalServerError =
      _$authSessionMetaGet500ResponseErrorEnum_internalServerError;

  static Serializer<AuthSessionMetaGet500ResponseErrorEnum> get serializer =>
      _$authSessionMetaGet500ResponseErrorEnumSerializer;

  const AuthSessionMetaGet500ResponseErrorEnum._(String name) : super(name);

  static BuiltSet<AuthSessionMetaGet500ResponseErrorEnum> get values =>
      _$authSessionMetaGet500ResponseErrorEnumValues;
  static AuthSessionMetaGet500ResponseErrorEnum valueOf(String name) =>
      _$authSessionMetaGet500ResponseErrorEnumValueOf(name);
}
