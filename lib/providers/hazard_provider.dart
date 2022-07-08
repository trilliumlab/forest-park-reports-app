import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/api/api.dart';
import 'package:forest_park_reports/models/hazard.dart';

// Contains all active hazards
final remoteActiveHazardProvider = FutureProvider<List<Hazard>>((ref) async {
  return await ref.watch(apiProvider).getActiveHazards();
});
