import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/hazard_new_response.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/model/queued_request.dart';
import 'package:forest_park_reports/model/snapped_latlng.dart';
import 'package:forest_park_reports/page/common/alert_banner.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:forest_park_reports/util/image_extensions.dart';
import 'package:forest_park_reports/util/offline_uploader.dart';
import 'package:image/image.dart' as img;
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';
part 'hazard_provider.g.dart';

@Riverpod(keepAlive: true)
class ActiveHazard extends _$ActiveHazard {
  @override
  Future<List<HazardModel>> build() async {
    final db = ref.watch(databaseProvider);

    final hazards = await db.select(db.hazardsTable).get();

    Timer.periodic(
      kHazardRefreshPeriod,
      (_) => refresh(),
    );

    if (hazards.isNotEmpty) {
      refresh();
      return hazards;
    }
    return await _fetch();
  }

  Future<List<HazardModel>> _fetch() async {
    final res = await ref.read(dioProvider).get("/geojson/reports.json");

    final data = Map<String, dynamic>.from(res.data as Map);
    final features = data["features"] as List? ?? [];

    final hazards = [
      for (final feature in features) _hazardFromGeoJsonFeature(feature),
    ];

    final db = ref.read(databaseProvider);
    await (db.delete(db.hazardsTable)..where((t) => t.offline.equals(false)))
        .go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.hazardsTable, hazards);
    });

    return hazards;
  }

  HazardModel _hazardFromGeoJsonFeature(dynamic feature) {
    final featureMap = Map<String, dynamic>.from(feature as Map);
    final properties =
        Map<String, dynamic>.from(featureMap["properties"] as Map);
    final geometry = Map<String, dynamic>.from(featureMap["geometry"] as Map);
    final coordinates = geometry["coordinates"] as List;

    final category = properties["category"] as String? ?? "other";
    final hazardType = category == "drainage"
        ? HazardType.flood
        : HazardType.values.firstWhere(
            (type) => type.name == category,
            orElse: () => HazardType.other,
          );

    return HazardModel(
      uuid: properties["localId"] as String? ?? featureMap["id"].toString(),
      time: DateTime.now().toUtc(),
      hazard: hazardType,
      location: SnappedLatLng(
        (properties["route"] as num?)?.toInt() ?? 0,
        (properties["trail"] as num?)?.toInt() ?? 0,
        LatLng(
          (coordinates[1] as num).toDouble(),
          (coordinates[0] as num).toDouble(),
        ),
      ),
      offline: false,
      image: properties["image"] as String?,
      blurHash: properties["blurHash"] as String?,
    );
  }

  Future<void> refresh() async {
    final newHazards = await _fetch();
    final newUuids = newHazards.map((h) => h.uuid);
    state = AsyncData([
      if (state.hasValue)
        for (final hazard in state.value!)
          if (hazard.offline && !newUuids.contains(hazard.uuid)) hazard,
      ...newHazards,
    ]);
  }

  Future<void> createHazard(
      {required String uuid,
      required HazardType hazard,
      required SnappedLatLng location,
      XFile? imageFile}) async {
    // Show alert that upload queued
    showAlertBanner(
      key: Key(uuid),
      child: const Text("Your report has been queued",
          key: Key("Your report has been queued")),
      color: Colors.grey,
    );

    // If we're passed an image, decode it.
    img.Image? image;
    if (imageFile != null) {
      final cmd = img.Command()
        ..decodeNamedImage(imageFile.path, await imageFile.readAsBytes());
      image = await cmd.getImageThread();
    }

    final hazardRequest = HazardModel.create(
      uuid: uuid,
      hazard: hazard,
      location: location,
      image: image != null ? kUuidGen.v1() : null,
      blurHash: image != null ? await image.getBlurHash() : null,
    );

    // Add offline hazard to app
    _addHazard(hazardRequest);

    await ref.read(dioProvider).post(
      "/reports/report",
      data: {
        "localId": hazardRequest.uuid,
        "creatorDeviceId": "flutter-dev",
        "category": hazardRequest.hazard.name == "flood"
            ? "drainage"
            : hazardRequest.hazard.name,
        "route": hazardRequest.location.trail,
        "trail": hazardRequest.location.node,
        "image": hazardRequest.image,
        "blurHash": hazardRequest.blurHash,
        "geometry": {
          "type": "Point",
          "coordinates": [
            hazardRequest.location.longitude,
            hazardRequest.location.latitude,
            0,
          ],
        },
      },
    );

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final imageDir =
        (await ref.read(directoryProvider(kImageDirectory).future))!;
    final imagePath = join(imageDir.path, "${hazardRequest.image!}.jpeg");
    await image.compressToFile(filePath: imagePath);

    await _uploadReportImage(
      imageUuid: hazardRequest.image!,
      imagePath: imagePath,
    );
  }

  Future<void> handleCreateResponse(HazardNewResponseModel response) async {
    // Show success notification
    showAlertBanner(
      key: Key(response.hazard.uuid),
      child: const Text("Report uploaded successfully",
          key: Key("Report uploaded successfully")),
      color: Colors.green,
    );

    _addHazard(response.hazard);

    // Add new update to hazard updates
    final updatesNotifier =
        ref.read(hazardUpdatesProvider(response.hazard.uuid).notifier);
    for (final update in response.updates) {
      await updatesNotifier.addHazardUpdate(update);
    }
  }

  Future<void> _uploadReportImage({
    required String imageUuid,
    required String imagePath,
  }) async {
    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        imagePath,
        filename: "$imageUuid.jpeg",
        contentType: DioMediaType("image", "jpeg"),
      ),
    });

    await ref.read(dioProvider).post(
          "/reports/image/$imageUuid",
          data: formData,
        );
  }

  Future<void> _addHazard(HazardModel hazard) async {
    // Add new HazardModel to state and db
    state = AsyncData([
      if (state.hasValue)
        for (final HazardModel existing in state.value ?? [])
          if (existing.uuid != hazard.uuid) existing,
      hazard,
    ]);
    final db = ref.read(databaseProvider);
    await db.into(db.hazardsTable).insertOnConflictUpdate(hazard);
  }

  Future updateHazard(
      {required String uuid,
      required String hazard,
      required bool active,
      XFile? imageFile}) async {
    // Show alert that update queued
    showAlertBanner(
      key: Key(uuid),
      child: const Text("Your report has been queued",
          key: Key("Your report has been queued")),
      color: Colors.green,
    );

    // If we're passed an image, decode it.
    img.Image? image;
    if (imageFile != null) {
      final cmd = img.Command()
        ..decodeNamedImage(imageFile.path, await imageFile.readAsBytes());
      image = await cmd.getImageThread();
    }

    final hazardUpdateRequest = HazardUpdateModel.create(
      uuid: uuid,
      hazard: hazard,
      active: active,
      image: image != null ? kUuidGen.v1() : null,
      blurHash: image != null ? await image.getBlurHash() : null,
    );

    // Add offline hazard update to app
    await ref
        .read(hazardUpdatesProvider(hazard).notifier)
        .addHazardUpdate(hazardUpdateRequest);
    // If it's a cleared report, remove hazard
    if (!active) {
      state = AsyncData([
        if (state.hasValue)
          for (final HazardModel existing in state.value ?? [])
            if (existing.uuid != hazard) existing,
      ]);
    }

    // Queue new hazard update request.
    OfflineUploader().enqueueJson(
      method: UploadMethod.POST,
      requestType: QueuedRequestType.updateHazard,
      associatedUuid: hazardUpdateRequest.uuid,
      url: "$kApiUrl/hazard/update",
      data: hazardUpdateRequest.toJson(),
    );

    // Now we try to upload the image if we have one
    if (image == null) {
      return;
    }
    // Compress and save image to file.
    final imageDir =
        (await ref.read(directoryProvider(kImageDirectory).future))!;
    final imagePath = join(imageDir.path, "${hazardUpdateRequest.image!}.jpeg");
    await image.compressToFile(filePath: imagePath);

    // Queue image upload
    await OfflineUploader().enqueueFile(
      method: UploadMethod.PUT,
      requestType: QueuedRequestType.imageUpload,
      associatedUuid: hazardUpdateRequest.uuid,
      url:
          "$kApiUrl/reports/image/${hazardUpdateRequest.image!}", //update photo upload URLS
      multipart: true,
      filePath: imagePath,
    );
  }

  Future<void> handleUpdateResponse(HazardUpdateModel hazardUpdate) async {
    // Show success notification
    showAlertBanner(
      key: Key(hazardUpdate.uuid),
      child: const Text("Report uploaded successfully",
          key: Key("Report uploaded successfully")),
      color: Colors.green,
    );

    // Add new update to hazard updates
    await ref
        .read(hazardUpdatesProvider(hazardUpdate.hazard).notifier)
        .addHazardUpdate(hazardUpdate);
  }
}

@Riverpod(keepAlive: true)
class HazardUpdates extends _$HazardUpdates {
  @override
  Future<HazardUpdateList> build(String hazard) async {
    final db = ref.watch(databaseProvider);
    final hazardUpdates =
        HazardUpdateList(await db.select(db.hazardUpdatesTable).get());
    if (hazardUpdates.isNotEmpty) {
      refresh();
      return hazardUpdates;
    }
    return await _fetch();
  }

  Future<HazardUpdateList> _fetch() async {
    final res = await ref.read(dioProvider).get("/hazard/$hazard");
    final updates = HazardUpdateList.fromJson(res.data);
    updates.sort((a, b) =>
        a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch);

    final db = ref.read(databaseProvider);
    await db.delete(db.hazardUpdatesTable).go();
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.hazardUpdatesTable, updates);
    });

    return updates;
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetch());
  }

  Future<void> addHazardUpdate(HazardUpdateModel hazardUpdate) async {
    // Add HazardUpdateModel to state and db
    state = AsyncData(HazardUpdateList([
      if (state.hasValue)
        for (final HazardUpdateModel existing in state.value ?? [])
          if (existing.uuid != hazardUpdate.uuid) existing,
      hazardUpdate,
    ]));
    final db = ref.read(databaseProvider);
    await db.into(db.hazardUpdatesTable).insertOnConflictUpdate(hazardUpdate);
  }
}

class SelectedHazardState {
  final bool moveCamera;
  final HazardModel? hazard;
  SelectedHazardState(this.moveCamera, [this.hazard]);
}

@Riverpod(keepAlive: true)
class SelectedHazard extends _$SelectedHazard {
  @override
  SelectedHazardState build() => SelectedHazardState(false);

  void selectAndMove(HazardModel hazard) {
    state = SelectedHazardState(true, hazard);
  }

  void select(HazardModel hazard) {
    state = SelectedHazardState(false, hazard);
  }

  void deselect() {
    state = SelectedHazardState(false);
  }
}
