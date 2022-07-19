import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';
import 'package:image_picker/image_picker.dart';

class ActiveHazardNotifier extends StateNotifier<List<Hazard>> {
  StateNotifierProviderRef ref;
  ActiveHazardNotifier(this.ref) : super([]) {
    refresh();
    Timer.periodic(
      const Duration(seconds: 10),
      (_) => refresh(),
    );
  }
  Future refresh() async {
    final res = await ref.read(dioProvider).get("/hazard/active");
    state = [
      for (final val in res.data)
        Hazard.fromJson(val)
    ];
  }
  Future<String?> uploadImage(XFile file) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path)
    });
    final res = await ref.read(dioProvider).post("/hazard/image", data: formData);
    return res.data['uuid'];
  }
  Future create(NewHazardRequest request) async {
    final res = await ref.read(dioProvider).post("/hazard/new", data: request.toJson());
    state = [...state, Hazard.fromJson(res.data)];
  }
}

final activeHazardProvider = StateNotifierProvider
  <ActiveHazardNotifier, List<Hazard>>((ref) => ActiveHazardNotifier(ref));

class HazardPhotoProgress {
  int received;
  int total;
  HazardPhotoProgress(this.received, this.total);
  double get progress {
    final p = received/total;
    return p.isNaN ? 0.0 : p.clamp(0, 1);
  }
}

final hazardPhotoProgressProvider = StateProvider.family<HazardPhotoProgress, String>((ref, uuid) {
  return HazardPhotoProgress(0, 0);
});

final hazardPhotoProvider = FutureProvider.family<Uint8List?, String>((ref, uuid) async {
  final res = await ref.read(dioProvider).get<Uint8List>(
    "/hazard/image/$uuid",
    options: Options(responseType: ResponseType.bytes),
    onReceiveProgress: (received, total) =>
        ref.read(hazardPhotoProgressProvider(uuid).notifier).state = HazardPhotoProgress(received, total),
  );
  return res.data;
});
