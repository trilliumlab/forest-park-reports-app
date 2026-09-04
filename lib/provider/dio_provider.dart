import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// The [Dio] client used for all backend requests. Carries a cookie jar
/// persisted to disk so the session established by [AuthNotifier.signIn]
/// survives app restarts.
@Riverpod(keepAlive: true)
Future<Dio> dio(Ref ref) async {
  final options = BaseOptions(baseUrl: kApiUrl);
  final dio = Dio(options);

  final cookieDir = await ref.watch(directoryProvider(kCookieDirectory).future);
  if (cookieDir != null) {
    dio.interceptors.add(CookieManager(PersistCookieJar(storage: FileStorage(cookieDir.path))));
  }

  return dio;
}
