import 'package:forest_park_reports/model/onboarding.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

@Riverpod(keepAlive: true)
class Onboarding extends _$Onboarding {
  @override
  OnboardingModel build() {
    // Load the default (unloaded) state immediately and fetch the persisted
    // value from shared preferences in the background.
    _fetch();
    return const OnboardingModel();
  }

  /// Marks onboarding as complete, either with a chosen [tier] or, if the
  /// user skipped, `null`.
  Future<void> complete(AccountTier? tier) async {
    state = state.copyWith(loaded: true, completed: true, tier: tier);
    final sp = await ref.read(sharedPreferencesProvider.future);
    state.persistToSharedPreferences(sp);
  }

  Future<void> _fetch() async {
    final sp = await ref.read(sharedPreferencesProvider.future);
    // Don't clobber a completion that happened while the fetch was in flight.
    if (!state.completed) {
      state = OnboardingModel.fromSharedPreferences(sp);
    }
  }
}
