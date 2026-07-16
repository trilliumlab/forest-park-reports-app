import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'directory_provider.dart';

part 'hazard_photo_provider.g.dart';

/// Provides the [Uint8List] image data for a photo of given UUID. Caches downloads locally.
@Riverpod(keepAlive: true)
class HazardPhoto extends _$HazardPhoto {
  @override
  Future<ImageProvider?> build(String uuid) async {
    Uint8List? data;
    // Web we can't cache images so fetch from server.
    if (kIsWeb) {
      data = await _fetch(uuid);
    } else {
      final imageName = "$uuid.jpeg";
      // Read all cached image filenames and see if any match the uuid we need.
      final imageDir = (await ref.watch(directoryProvider(kImageDirectory).future))!;
      final hasImage = await imageDir.list().any((f) => f.uri.pathSegments.last == imageName);
      // If image doesn't exist in cache (or path exists but is not a File) fetch from server.
      if (!hasImage) {
        data = await _fetch(uuid);
      } else {
        // Otherwise load image from cache
        final imageFile = File(join(imageDir.path, imageName));
        data = await imageFile.readAsBytes();
      }
    }
    if (data == null) {
      return null;
    }
    return MemoryImage(data);
  }

  Future<Uint8List?> _fetch(String uuid) async {
    final res = await ref.read(dioProvider).get<Uint8List>(
      "/reports/image/$uuid", //update photo display
      options: Options(responseType: ResponseType.bytes),
    );
    final data = res.data;
    // If we're not on web we should save the image to the cache.
    if (!kIsWeb && data != null) {
      // No await since we want to immediately display the image and save it in the background.
      _saveImage(uuid, data);
    }
    return data;
  }

  Future<void> _saveImage(String uuid, Uint8List data) async {
    // Get image path and ensure exists.
    final imageDir = (await ref.read(directoryProvider(kImageDirectory).future))!;
    final imageFile = File(join(imageDir.path, "$uuid.jpeg"));
    await imageFile.create();
    // Write data.
    await imageFile.writeAsBytes(data);
  }
}
