import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/api/api.dart';
import 'package:forest_park_reports/models/hazard.dart';

Timer? _refresh;
// Contains all active hazards
final FutureProvider<List<Hazard>> remoteActiveHazardProvider = FutureProvider<List<Hazard>>((ref) async {
  // this is a really hacky way to auto refresh the hazards every 30 seconds
  if (_refresh != null) {_refresh!.cancel();}
  _refresh = Timer(const Duration(seconds: 30), () {
    ref.refresh(remoteActiveHazardProvider);
  });
  return await ref.watch(apiProvider).getActiveHazards();
});
