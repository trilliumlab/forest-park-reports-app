import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/dio_provider.dart';

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
  Future create(NewHazardRequest request) async {
    final res = await ref.read(dioProvider).post("/hazard/new", data: request.toJson());
    state = [...state, Hazard.fromJson(res.data)];
  }
}

final activeHazardProvider = StateNotifierProvider
  <ActiveHazardNotifier, List<Hazard>>((ref) => ActiveHazardNotifier(ref));
