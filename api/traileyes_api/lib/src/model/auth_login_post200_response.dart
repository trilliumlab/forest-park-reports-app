//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login_post200_response.g.dart';

/// AuthLoginPost200Response
///
/// Properties:
/// * [userVerified]
/// * [requiresSecondFactor]
/// * [enabledSecondFactors]
@BuiltValue()
abstract class AuthLoginPost200Response
    implements
        Built<AuthLoginPost200Response, AuthLoginPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'userVerified')
  bool get userVerified;

  @BuiltValueField(wireName: r'requiresSecondFactor')
  bool get requiresSecondFactor;

  @BuiltValueField(wireName: r'enabledSecondFactors')
  BuiltList<AuthLoginPost200ResponseEnabledSecondFactorsEnum>
      get enabledSecondFactors;
  // enum enabledSecondFactorsEnum {  email,  totp,  };

  AuthLoginPost200Response._();

  factory AuthLoginPost200Response(
          [void updates(AuthLoginPost200ResponseBuilder b)]) =
      _$AuthLoginPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLoginPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLoginPost200Response> get serializer =>
      _$AuthLoginPost200ResponseSerializer();
}

class _$AuthLoginPost200ResponseSerializer
    implements PrimitiveSerializer<AuthLoginPost200Response> {
  @override
  final Iterable<Type> types = const [
    AuthLoginPost200Response,
    _$AuthLoginPost200Response
  ];

  @override
  final String wireName = r'AuthLoginPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLoginPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userVerified';
    yield serializers.serialize(
      object.userVerified,
      specifiedType: const FullType(bool),
    );
    yield r'requiresSecondFactor';
    yield serializers.serialize(
      object.requiresSecondFactor,
      specifiedType: const FullType(bool),
    );
    yield r'enabledSecondFactors';
    yield serializers.serialize(
      object.enabledSecondFactors,
      specifiedType: const FullType(BuiltList,
          [FullType(AuthLoginPost200ResponseEnabledSecondFactorsEnum)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthLoginPost200Response object, {
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
    required AuthLoginPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.userVerified = valueDes;
          break;
        case r'requiresSecondFactor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.requiresSecondFactor = valueDes;
          break;
        case r'enabledSecondFactors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(AuthLoginPost200ResponseEnabledSecondFactorsEnum)]),
          ) as BuiltList<AuthLoginPost200ResponseEnabledSecondFactorsEnum>;
          result.enabledSecondFactors.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthLoginPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLoginPost200ResponseBuilder();
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

class AuthLoginPost200ResponseEnabledSecondFactorsEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'email')
  static const AuthLoginPost200ResponseEnabledSecondFactorsEnum email =
      _$authLoginPost200ResponseEnabledSecondFactorsEnum_email;
  @BuiltValueEnumConst(wireName: r'totp', fallback: true)
  static const AuthLoginPost200ResponseEnabledSecondFactorsEnum totp =
      _$authLoginPost200ResponseEnabledSecondFactorsEnum_totp;

  static Serializer<AuthLoginPost200ResponseEnabledSecondFactorsEnum>
      get serializer =>
          _$authLoginPost200ResponseEnabledSecondFactorsEnumSerializer;

  const AuthLoginPost200ResponseEnabledSecondFactorsEnum._(String name)
      : super(name);

  static BuiltSet<AuthLoginPost200ResponseEnabledSecondFactorsEnum>
      get values => _$authLoginPost200ResponseEnabledSecondFactorsEnumValues;
  static AuthLoginPost200ResponseEnabledSecondFactorsEnum valueOf(
          String name) =>
      _$authLoginPost200ResponseEnabledSecondFactorsEnumValueOf(name);
}
