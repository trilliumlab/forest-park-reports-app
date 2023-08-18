import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting_model.g.dart';
part 'setting_model.freezed.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const SettingsModel._();
  const factory SettingsModel({
    required bool isDarkModeEnabled,
    required bool isBackgroundGPSEnabled,
    required String selectedMapQuality,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}
