import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  /// `authErrorMessage`.
  ///
  /// Does not establish a session (the backend requires email verification
  /// before sign-in succeeds), so the session stays unauthenticated until
  /// [signIn] is called separately.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required AccountTier tier,
  }) async {
    final dio = await ref.read(dioProvider.future);
    await dio.post('/auth/sign-up/email', data: {
      'name': name,
      'email': email,
      'password': password,
      'tier': tier.value,
    });
  }

  /// Signs in against an existing, verified account. Throws a
  /// [DioException] on failure (e.g. wrong password, or email not yet
  /// verified); see `authErrorMessage`.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final dio = await ref.read(dioProvider.future);
    await dio.post('/auth/sign-in/email', data: {
      'email': email,
      'password': password,
    });
    ref.invalidate(sessionProvider);
  }
}

/// The currently logged-in user's id, or `null` if there is no session.
/// Refreshed after [Auth.signIn]; used to attribute report submissions to
/// an account.
@Riverpod(keepAlive: true)
Future<String?> session(Ref ref) async {
  final dio = await ref.read(dioProvider.future);
  final res = await dio.get('/auth/get-session');
  final data = res.data;
  if (data is! Map) return null;
  final user = data['user'];
  if (user is! Map) return null;
  return user['id'] as String?;
}

/// Extracts a user-facing message from a failed [Auth.signUp] or
/// [Auth.signIn] call.
String authErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return "Something went wrong, please try again";
}
