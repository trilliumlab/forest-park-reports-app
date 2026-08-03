import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'queued_request.g.dart';
part 'queued_request.freezed.dart';

@freezed
class QueuedRequestModel
    with _$QueuedRequestModel
    implements drift.Insertable<QueuedRequestModel> {
  const QueuedRequestModel._();
  const factory QueuedRequestModel({
    required String taskId,
    required QueuedRequestType requestType,
    required String filePath,
    required String associatedUuid,
  }) = _QueuedRequestModel;

  /// Maps a [QueuedRequestModel] to a database [QueueTable] row.
  @override
  Map<String, drift.Expression<Object>> toColumns(bool nullToAbsent) =>
      QueueTableCompanion(
        taskId: drift.Value(taskId),
        requestType: drift.Value(requestType),
        filePath: drift.Value(filePath),
        associatedUuid: drift.Value(associatedUuid)
      ).toColumns(nullToAbsent);

  factory QueuedRequestModel.fromJson(Map<String, dynamic> json) =>
      _$QueuedRequestModelFromJson(json);
}

enum QueuedRequestType {
  newHazard,
  imageUpload,
  updateHazard,
  newReport;
}

@freezed
class QueuedRequestResponseModel with _$QueuedRequestResponseModel {
  const QueuedRequestResponseModel._();

  const factory QueuedRequestResponseModel({
    required QueuedRequestType requestType,
    required String? response,
  }) = _QueuedRequestResponseModel;

  factory QueuedRequestResponseModel.fromJson(Map<String, dynamic> json) =>
      _$QueuedRequestResponseModelFromJson(json);
}
