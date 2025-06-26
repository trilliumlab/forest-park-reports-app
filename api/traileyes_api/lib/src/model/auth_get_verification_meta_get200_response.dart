//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:traileyes_api/src/model/auth_get_verification_meta_get200_response_one_of.dart';
import 'package:traileyes_api/src/model/auth_get_verification_meta_get200_response_one_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'auth_get_verification_meta_get200_response.g.dart';

/// AuthGetVerificationMetaGet200Response
///
/// Properties:
/// * [userVerified]
/// * [secondsUntilCanResend]
/// * [email]
/// * [hasActiveCode]
/// * [shouldResend]
@BuiltValue()
abstract class AuthGetVerificationMetaGet200Response
    implements
        Built<AuthGetVerificationMetaGet200Response,
            AuthGetVerificationMetaGet200ResponseBuilder> {
  /// One Of [AuthGetVerificationMetaGet200ResponseOneOf], [AuthGetVerificationMetaGet200ResponseOneOf1]
  OneOf get oneOf;

  AuthGetVerificationMetaGet200Response._();

  factory AuthGetVerificationMetaGet200Response(
          [void updates(AuthGetVerificationMetaGet200ResponseBuilder b)]) =
      _$AuthGetVerificationMetaGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthGetVerificationMetaGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthGetVerificationMetaGet200Response> get serializer =>
      _$AuthGetVerificationMetaGet200ResponseSerializer();
}

class _$AuthGetVerificationMetaGet200ResponseSerializer
    implements PrimitiveSerializer<AuthGetVerificationMetaGet200Response> {
  @override
  final Iterable<Type> types = const [
    AuthGetVerificationMetaGet200Response,
    _$AuthGetVerificationMetaGet200Response
  ];

  @override
  final String wireName = r'AuthGetVerificationMetaGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthGetVerificationMetaGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    AuthGetVerificationMetaGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  AuthGetVerificationMetaGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthGetVerificationMetaGet200ResponseBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(AuthGetVerificationMetaGet200ResponseOneOf),
      FullType(AuthGetVerificationMetaGet200ResponseOneOf1),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}
