import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_id_provider.g.dart';

const _kDeviceIdKey = 'device_id';

/// A random id identifying this device/install, generated once and persisted
/// locally. Used as `creatorDeviceId` when submitting reports to the new
/// backend, which has no concept of user accounts yet.
@Riverpod(keepAlive: true)
Future<String> deviceId(Ref ref) async {
  final sp = await ref.read(sharedPreferencesProvider.future);
  final existing = sp.getString(_kDeviceIdKey);
  if (existing != null) {
    return existing;
  }
  final id = kUuidGen.v4();
  await sp.setString(_kDeviceIdKey, id);
  return id;
}
