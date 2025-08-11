//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:traileyes_api/src/model/reports_post_report_request_geometry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_post_report_request.g.dart';

/// ReportsPostReportRequest
///
/// Properties:
/// * [creatorDeviceId]
/// * [category]
/// * [route]
/// * [trail]
/// * [geometry]
/// * [id]
/// * [localId]
/// * [creatorUserId]
/// * [image]
/// * [blurHash]
/// * [status]
/// * [reportedAt]
/// * [updatedAt]
@BuiltValue()
abstract class ReportsPostReportRequest
    implements
        Built<ReportsPostReportRequest, ReportsPostReportRequestBuilder> {
  @BuiltValueField(wireName: r'creatorDeviceId')
  String get creatorDeviceId;

  @BuiltValueField(wireName: r'category')
  ReportsPostReportRequestCategoryEnum get category;
  // enum categoryEnum {  other,  fallenTree,  drainage,  erosion,  structureFailure,  damagedSign,  seasonal,  };

  @BuiltValueField(wireName: r'route')
  int get route;

  @BuiltValueField(wireName: r'trail')
  int get trail;

  @BuiltValueField(wireName: r'geometry')
  ReportsPostReportRequestGeometry get geometry;

  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'localId')
  String? get localId;

  @BuiltValueField(wireName: r'creatorUserId')
  String? get creatorUserId;

  @BuiltValueField(wireName: r'image')
  String? get image;

  @BuiltValueField(wireName: r'blurHash')
  String? get blurHash;

  @BuiltValueField(wireName: r'status')
  ReportsPostReportRequestStatusEnum? get status;
  // enum statusEnum {  open,  confirmed,  inProgress,  closed,  };

  @BuiltValueField(wireName: r'reportedAt')
  DateTime? get reportedAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime? get updatedAt;

  ReportsPostReportRequest._();

  factory ReportsPostReportRequest(
          [void updates(ReportsPostReportRequestBuilder b)]) =
      _$ReportsPostReportRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsPostReportRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsPostReportRequest> get serializer =>
      _$ReportsPostReportRequestSerializer();
}

class _$ReportsPostReportRequestSerializer
    implements PrimitiveSerializer<ReportsPostReportRequest> {
  @override
  final Iterable<Type> types = const [
    ReportsPostReportRequest,
    _$ReportsPostReportRequest
  ];

  @override
  final String wireName = r'ReportsPostReportRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsPostReportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'creatorDeviceId';
    yield serializers.serialize(
      object.creatorDeviceId,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(ReportsPostReportRequestCategoryEnum),
    );
    yield r'route';
    yield serializers.serialize(
      object.route,
      specifiedType: const FullType(int),
    );
    yield r'trail';
    yield serializers.serialize(
      object.trail,
      specifiedType: const FullType(int),
    );
    yield r'geometry';
    yield serializers.serialize(
      object.geometry,
      specifiedType: const FullType(ReportsPostReportRequestGeometry),
    );
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.localId != null) {
      yield r'localId';
      yield serializers.serialize(
        object.localId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.creatorUserId != null) {
      yield r'creatorUserId';
      yield serializers.serialize(
        object.creatorUserId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.image != null) {
      yield r'image';
      yield serializers.serialize(
        object.image,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.blurHash != null) {
      yield r'blurHash';
      yield serializers.serialize(
        object.blurHash,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ReportsPostReportRequestStatusEnum),
      );
    }
    if (object.reportedAt != null) {
      yield r'reportedAt';
      yield serializers.serialize(
        object.reportedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedAt != null) {
      yield r'updatedAt';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportsPostReportRequest object, {
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
    required ReportsPostReportRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'creatorDeviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.creatorDeviceId = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportsPostReportRequestCategoryEnum),
          ) as ReportsPostReportRequestCategoryEnum;
          result.category = valueDes;
          break;
        case r'route':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.route = valueDes;
          break;
        case r'trail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trail = valueDes;
          break;
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportsPostReportRequestGeometry),
          ) as ReportsPostReportRequestGeometry;
          result.geometry.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'localId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.localId = valueDes;
          break;
        case r'creatorUserId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.creatorUserId = valueDes;
          break;
        case r'image':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.image = valueDes;
          break;
        case r'blurHash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.blurHash = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportsPostReportRequestStatusEnum),
          ) as ReportsPostReportRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'reportedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.reportedAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportsPostReportRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsPostReportRequestBuilder();
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

class ReportsPostReportRequestCategoryEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'other')
  static const ReportsPostReportRequestCategoryEnum other =
      _$reportsPostReportRequestCategoryEnum_other;
  @BuiltValueEnumConst(wireName: r'fallenTree')
  static const ReportsPostReportRequestCategoryEnum fallenTree =
      _$reportsPostReportRequestCategoryEnum_fallenTree;
  @BuiltValueEnumConst(wireName: r'drainage')
  static const ReportsPostReportRequestCategoryEnum drainage =
      _$reportsPostReportRequestCategoryEnum_drainage;
  @BuiltValueEnumConst(wireName: r'erosion')
  static const ReportsPostReportRequestCategoryEnum erosion =
      _$reportsPostReportRequestCategoryEnum_erosion;
  @BuiltValueEnumConst(wireName: r'structureFailure')
  static const ReportsPostReportRequestCategoryEnum structureFailure =
      _$reportsPostReportRequestCategoryEnum_structureFailure;
  @BuiltValueEnumConst(wireName: r'damagedSign')
  static const ReportsPostReportRequestCategoryEnum damagedSign =
      _$reportsPostReportRequestCategoryEnum_damagedSign;
  @BuiltValueEnumConst(wireName: r'seasonal', fallback: true)
  static const ReportsPostReportRequestCategoryEnum seasonal =
      _$reportsPostReportRequestCategoryEnum_seasonal;

  static Serializer<ReportsPostReportRequestCategoryEnum> get serializer =>
      _$reportsPostReportRequestCategoryEnumSerializer;

  const ReportsPostReportRequestCategoryEnum._(String name) : super(name);

  static BuiltSet<ReportsPostReportRequestCategoryEnum> get values =>
      _$reportsPostReportRequestCategoryEnumValues;
  static ReportsPostReportRequestCategoryEnum valueOf(String name) =>
      _$reportsPostReportRequestCategoryEnumValueOf(name);
}

class ReportsPostReportRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const ReportsPostReportRequestStatusEnum open =
      _$reportsPostReportRequestStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'confirmed')
  static const ReportsPostReportRequestStatusEnum confirmed =
      _$reportsPostReportRequestStatusEnum_confirmed;
  @BuiltValueEnumConst(wireName: r'inProgress')
  static const ReportsPostReportRequestStatusEnum inProgress =
      _$reportsPostReportRequestStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'closed', fallback: true)
  static const ReportsPostReportRequestStatusEnum closed =
      _$reportsPostReportRequestStatusEnum_closed;

  static Serializer<ReportsPostReportRequestStatusEnum> get serializer =>
      _$reportsPostReportRequestStatusEnumSerializer;

  const ReportsPostReportRequestStatusEnum._(String name) : super(name);

  static BuiltSet<ReportsPostReportRequestStatusEnum> get values =>
      _$reportsPostReportRequestStatusEnumValues;
  static ReportsPostReportRequestStatusEnum valueOf(String name) =>
      _$reportsPostReportRequestStatusEnumValueOf(name);
}
