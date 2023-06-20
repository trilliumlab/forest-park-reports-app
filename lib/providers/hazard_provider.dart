import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hazard_provider.g.dart';

@riverpod
class ActiveHazard extends _$ActiveHazard {
  @override
  List<HazardModel> build() {
    refresh();
    Timer.periodic(
      const Duration(seconds: 10),
          (_) => refresh(),
    );
    return [];
  }
  Future refresh() async {
    final res = await ref.read(dioProvider).get("/hazard/active");
    state = [
      for (final val in res.data)
        HazardModel.fromJson(val)
    ];
  }
  Future<String?> uploadImage(XFile file, {void Function(int, int)? onSendProgress}) async {
    final image = await FlutterImageCompress.compressWithFile(
        file.path,
        keepExif: true,
        quality: 80
    );
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(image!),
    });
    final res = await ref.read(dioProvider).post(
        "/hazard/image",
        data: formData,
        options: Options(
          headers: {
            'Accept-Ranged': 'bytes'
          },
        ),
        onSendProgress: onSendProgress
    );
    return res.data['uuid'];
  }
  Future create(NewHazardRequestModel request) async {
    final res = await ref.read(dioProvider).post("/hazard/new", data: request.toJson());
    state = [...state, HazardModel.fromJson(res.data)];
  }
}

class HazardUpdateList extends ListBase<HazardUpdateModel> {
  final List<HazardUpdateModel> l;

  HazardUpdateList(this.l);

  @override
  set length(int newLength) { l.length = newLength; }
  @override
  int get length => l.length;
  @override
  HazardUpdateModel operator [](int index) => l[index];
  @override
  void operator []=(int index, HazardUpdateModel value) { l[index] = value; }

  String? get lastImage => lastWhereOrNull((e) => e.image != null)?.image;
}

@riverpod
class HazardUpdates extends _$HazardUpdates {
  late final String hazard;
  @override
  HazardUpdateList build(String hazard) {
    this.hazard = hazard;
    refresh();
    return HazardUpdateList([]);
  }
  Future refresh() async {
    final res = await ref.read(dioProvider).get("/hazard/$hazard");
    final updates = HazardUpdateList([
      for (final val in res.data)
        HazardUpdateModel.fromJson(val)
    ]);
    updates.sort((a, b) => a.time.millisecondsSinceEpoch - b.time.millisecondsSinceEpoch);
    state = updates;
  }

  Future create(UpdateHazardRequestModel request) async {
    final res = await ref.read(dioProvider).post("/hazard/update", data: request.toJson());
    state = HazardUpdateList([...state, HazardUpdateModel.fromJson(res.data)]);
  }
}

class HazardPhotoProgressState {
  int transmitted;
  int total;
  HazardPhotoProgressState(this.transmitted, this.total);
  bool get isComplete => transmitted == total;
  double get progress {
    final p = transmitted/total;
    return p.isNaN ? 0.0 : p.clamp(0, 1);
  }
}

@riverpod
class HazardPhotoProgress extends _$HazardPhotoProgress {
  @override
  HazardPhotoProgressState build(String uuid) => HazardPhotoProgressState(0, 0);

  void updateProgress(int transmitted, int total) =>
      state = HazardPhotoProgressState(transmitted, total);
}

@riverpod
class HazardPhoto extends _$HazardPhoto {
  @override
  Future<Uint8List?> build(String uuid) async {
    final res = await ref.read(dioProvider).get<Uint8List>(
      "/hazard/image/$uuid",
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (received, total) =>
          ref.read(hazardPhotoProgressProvider(uuid).notifier)
              .updateProgress(received, total),
    );
    return res.data;
  }
}

class SelectedHazardState {
  final bool moveCamera;
  final HazardModel? hazard;
  SelectedHazardState(this.moveCamera, [this.hazard]);
}

@riverpod
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
