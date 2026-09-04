import 'package:dio/dio.dart';
import 'package:forest_park_reports/model/onboarding.dart';
import 'package:forest_park_reports/provider/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  void build() {}

  /// Registers a new account against the backend's sign-up endpoint.
  /// Throws a [DioException] on failure (e.g. email already in use); the
  /// response body is `{"code": ..., "message": ...}`, see
  /// `signUpErrorMessage`.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required AccountTier tier,
  }) async {
    final dio = ref.read(dioProvider);
    await dio.post('/auth/sign-up/email', data: {
      'name': name,
      'email': email,
      'password': password,
      'tier': tier.value,
    });
  }
}

/// Extracts a user-facing message from a failed [Auth.signUp] call.
String signUpErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return "Something went wrong, please try again";
}
