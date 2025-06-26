//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:traileyes_api/src/model/auth_session_meta_get401_response.dart';
import 'package:traileyes_api/src/model/auth_login_post401_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'auth_verify_email_post401_response.g.dart';

/// AuthVerifyEmailPost401Response
///
/// Properties:
/// * [statusCode]
/// * [message]
/// * [error]
/// * [code]
@BuiltValue()
abstract class AuthVerifyEmailPost401Response
    implements
        Built<AuthVerifyEmailPost401Response,
            AuthVerifyEmailPost401ResponseBuilder> {
  /// One Of [AuthLoginPost401Response], [AuthSessionMetaGet401Response]
  OneOf get oneOf;

  AuthVerifyEmailPost401Response._();

  factory AuthVerifyEmailPost401Response(
          [void updates(AuthVerifyEmailPost401ResponseBuilder b)]) =
      _$AuthVerifyEmailPost401Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyEmailPost401ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyEmailPost401Response> get serializer =>
      _$AuthVerifyEmailPost401ResponseSerializer();
}

class _$AuthVerifyEmailPost401ResponseSerializer
    implements PrimitiveSerializer<AuthVerifyEmailPost401Response> {
  @override
  final Iterable<Type> types = const [
    AuthVerifyEmailPost401Response,
    _$AuthVerifyEmailPost401Response
  ];

  @override
  final String wireName = r'AuthVerifyEmailPost401Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyEmailPost401Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AuthVerifyEmailPost401Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  AuthVerifyEmailPost401Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyEmailPost401ResponseBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(AuthSessionMetaGet401Response),
      FullType(AuthLoginPost401Response),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class AuthVerifyEmailPost401ResponseStatusCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'401', fallback: true)
  static const AuthVerifyEmailPost401ResponseStatusCodeEnum n401 =
      _$authVerifyEmailPost401ResponseStatusCodeEnum_n401;

  static Serializer<AuthVerifyEmailPost401ResponseStatusCodeEnum>
      get serializer =>
          _$authVerifyEmailPost401ResponseStatusCodeEnumSerializer;

  const AuthVerifyEmailPost401ResponseStatusCodeEnum._(String name)
      : super(name);

  static BuiltSet<AuthVerifyEmailPost401ResponseStatusCodeEnum> get values =>
      _$authVerifyEmailPost401ResponseStatusCodeEnumValues;
  static AuthVerifyEmailPost401ResponseStatusCodeEnum valueOf(String name) =>
      _$authVerifyEmailPost401ResponseStatusCodeEnumValueOf(name);
}

class AuthVerifyEmailPost401ResponseErrorEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Unauthorized', fallback: true)
  static const AuthVerifyEmailPost401ResponseErrorEnum unauthorized =
      _$authVerifyEmailPost401ResponseErrorEnum_unauthorized;

  static Serializer<AuthVerifyEmailPost401ResponseErrorEnum> get serializer =>
      _$authVerifyEmailPost401ResponseErrorEnumSerializer;

  const AuthVerifyEmailPost401ResponseErrorEnum._(String name) : super(name);

  static BuiltSet<AuthVerifyEmailPost401ResponseErrorEnum> get values =>
      _$authVerifyEmailPost401ResponseErrorEnumValues;
  static AuthVerifyEmailPost401ResponseErrorEnum valueOf(String name) =>
      _$authVerifyEmailPost401ResponseErrorEnumValueOf(name);
}

class AuthVerifyEmailPost401ResponseCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'INVALID_CREDENTIALS', fallback: true)
  static const AuthVerifyEmailPost401ResponseCodeEnum INVALID_CREDENTIALS =
      _$authVerifyEmailPost401ResponseCodeEnum_INVALID_CREDENTIALS;

  static Serializer<AuthVerifyEmailPost401ResponseCodeEnum> get serializer =>
      _$authVerifyEmailPost401ResponseCodeEnumSerializer;

  const AuthVerifyEmailPost401ResponseCodeEnum._(String name) : super(name);

  static BuiltSet<AuthVerifyEmailPost401ResponseCodeEnum> get values =>
      _$authVerifyEmailPost401ResponseCodeEnumValues;
  static AuthVerifyEmailPost401ResponseCodeEnum valueOf(String name) =>
      _$authVerifyEmailPost401ResponseCodeEnumValueOf(name);
}
