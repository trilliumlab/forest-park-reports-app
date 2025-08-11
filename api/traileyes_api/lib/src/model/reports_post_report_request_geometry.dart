//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_post_report_request_geometry.g.dart';

/// ReportsPostReportRequestGeometry
///
/// Properties:
/// * [coordinates]
/// * [type]
@BuiltValue()
abstract class ReportsPostReportRequestGeometry
    implements
        Built<ReportsPostReportRequestGeometry,
            ReportsPostReportRequestGeometryBuilder> {
  @BuiltValueField(wireName: r'coordinates')
  JsonObject? get coordinates;

  @BuiltValueField(wireName: r'type')
  JsonObject? get type;

  ReportsPostReportRequestGeometry._();

  factory ReportsPostReportRequestGeometry(
          [void updates(ReportsPostReportRequestGeometryBuilder b)]) =
      _$ReportsPostReportRequestGeometry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsPostReportRequestGeometryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsPostReportRequestGeometry> get serializer =>
      _$ReportsPostReportRequestGeometrySerializer();
}

class _$ReportsPostReportRequestGeometrySerializer
    implements PrimitiveSerializer<ReportsPostReportRequestGeometry> {
  @override
  final Iterable<Type> types = const [
    ReportsPostReportRequestGeometry,
    _$ReportsPostReportRequestGeometry
  ];

  @override
  final String wireName = r'ReportsPostReportRequestGeometry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsPostReportRequestGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'coordinates';
    yield object.coordinates == null
        ? null
        : serializers.serialize(
            object.coordinates,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'type';
    yield object.type == null
        ? null
        : serializers.serialize(
            object.type,
            specifiedType: const FullType.nullable(JsonObject),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportsPostReportRequestGeometry object, {
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
    required ReportsPostReportRequestGeometryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'coordinates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.coordinates = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportsPostReportRequestGeometry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsPostReportRequestGeometryBuilder();
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
