import 'package:forest_park_reports/model/settings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding.freezed.dart';

const _kCompletedKey = 'onboarding.completed';
const _kTierKey = 'onboarding.tier';

/// Mirrors the backend's `account_tier` enum (tier 1 has no representation
/// there since tier-1 users don't have accounts at all).
enum AccountTier implements SelectionOption<String> {
  hiker(
    displayName: 'Regular Hiker',
    value: '2',
  ),
  staff(
    displayName: 'Park Staff',
    value: '3',
  );

  @override
  final String displayName;
  @override
  final String value;

  const AccountTier({required this.displayName, required this.value});
}

@freezed
class OnboardingModel with _$OnboardingModel {
  const OnboardingModel._();

  const factory OnboardingModel({
    // Whether the persisted value has been read from SharedPreferences yet.
    // Used to avoid showing the signup page before we know if it's needed.
    @Default(false) bool loaded,
    @Default(false) bool completed,
    // Null means the user skipped (tier 1 / no account).
    AccountTier? tier,
  }) = _OnboardingModel;

  /// Creates a new [OnboardingModel] from the value persisted to
  /// [SharedPreferences].
  factory OnboardingModel.fromSharedPreferences(SharedPreferences sp) {
    final tierValue = sp.getString(_kTierKey);
    return OnboardingModel(
      loaded: true,
      completed: sp.getBool(_kCompletedKey) ?? false,
      tier: AccountTier.values.where((t) => t.value == tierValue).firstOrNull,
    );
  }

  /// Persists this choice to [SharedPreferences].
  void persistToSharedPreferences(SharedPreferences sp) {
    sp.setBool(_kCompletedKey, completed);
    if (tier != null) {
      sp.setString(_kTierKey, tier!.value);
    } else {
      sp.remove(_kTierKey);
    }
  }
}
