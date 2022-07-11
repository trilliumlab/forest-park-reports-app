import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) {
  const baseUrl = "http://192.168.1.100:3000/api/v1/";
  final options = BaseOptions(
    baseUrl: baseUrl
  );
  return Dio(options);
});
