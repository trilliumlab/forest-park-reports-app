import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) {
  const baseUrl = "https://forestpark.elliotnash.org/api/v1/";
  final options = BaseOptions(
    baseUrl: baseUrl
  );
  return Dio(options);
});
