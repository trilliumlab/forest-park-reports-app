import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/settings.dart';
import 'package:forest_park_reports/page/login_page.dart';
import 'package:forest_park_reports/page/signup_page.dart';
import 'package:forest_park_reports/page/settings_page/settings_page_scaffold.dart';
import 'package:forest_park_reports/page/settings_page/selection_setting_widget.dart';
import 'package:forest_park_reports/page/settings_page/toggle_setting_widget.dart';
import 'package:forest_park_reports/page/settings_page/button_setting_widget.dart';
import 'package:forest_park_reports/page/common/confirmation.dart';
import 'package:forest_park_reports/page/settings_page/settings_section.dart';
import 'package:forest_park_reports/provider/auth_provider.dart';
import 'package:forest_park_reports/provider/database_provider.dart';
import 'package:forest_park_reports/provider/directory_provider.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final session = ref.watch(sessionProvider);

    return SettingsPageScaffold(
      title: "Settings",
      previousPageTitle: "Home",
      children: [
        SettingsSection(
          label: "Account",
          children: [
            if (session.valueOrNull != null)
              ButtonSettingWidget(
                name: "Log Out",
                buttonStyle: ButtonSettingStyle.danger,
                onTap: () => ref.read(authProvider.notifier).signOut(),
              )
            else ...[
              ButtonSettingWidget(
                name: "Log In",
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                )),
              ),
              ButtonSettingWidget(
                name: "Sign Up",
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SignupPage(),
                )),
              ),
            ],
          ],
        ),
        SettingsSection(
          label: "Theme",
          children: [
            /* FIXME: Currently the theme can't update when a custom platform is set...
             * Flutter Platform Widgets bug
             */
            // SelectionSettingWidget(
            //   name: "UI Theme",
            //   pageTitle: "Settings",
            //   options: UITheme.values,
            //   selectedOption: settings.uiTheme,
            //   onSelection: (option) {
            //     PlatformProvider.of(context)?.changeToCupertinoPlatform();
            //     ref.read(settingsProvider.notifier).update(settings.copyWith(
            //       uiTheme: option,
            //     ));
            //   },
            // ),
            SelectionSettingWidget(
              name: "Color Theme",
              pageTitle: "Settings",
              options: ColorTheme.values,
              selectedOption: settings.colorTheme,
              onSelection: (option) {
                ref.read(settingsProvider.notifier).update(settings.copyWith(
                  colorTheme: option,
                ));
              },
            ),
          ],
        ),
        SettingsSection(
          label: "Map",
          children: [
            ToggleSettingWidget(
              name: "Retina Mode",
              value: settings.retinaMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).update(settings.copyWith(
                  retinaMode: value,
                ));
              },
            )
          ],
        ),
        SettingsSection(
          label: "Advanced",
          children: [
            ButtonSettingWidget(
              name: "Reset database",
              buttonStyle: ButtonSettingStyle.danger,
              confirmation: ConfirmationInfo(
                  title: "Reset database?",
                  content: "All settings and offline reports will be lost."),
              onTap: () async {
                //  Delete database
                await ref.read(databaseProvider.notifier).delete();
                // Delete cache
                final imageDir = (await ref.read(directoryProvider(kImageDirectory).future))!;
                await imageDir.delete(recursive: true);
                // Clear upload queue
                await FlutterUploader().cancelAll();
                await FlutterUploader().clearUploads();
              },
            )
          ],
        ),
      ],
    );
  }
}
