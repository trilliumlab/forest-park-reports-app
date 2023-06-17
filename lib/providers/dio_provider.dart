import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/consts.dart';

final dioProvider = Provider((ref) {
  final options = BaseOptions(
    baseUrl: kApiUrl
  );
  return Dio(options);
});
