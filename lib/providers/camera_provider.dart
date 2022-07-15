import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraProvider = FutureProvider<CameraDescription>((ref) async {
  final cameras = await availableCameras();
  return cameras.first;
});
