import 'package:dio/dio.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final options = BaseOptions(
      baseUrl: kApiUrl
  );
  return Dio(options);
}
