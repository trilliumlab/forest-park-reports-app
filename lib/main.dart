import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forest_park_reports/env.dart';
import 'package:forest_park_reports/provider/settings_provider.dart';
import 'package:forest_park_reports/util/offline_uploader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/page/home_page.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final providerContainer = ProviderContainer();
final GlobalKey homeKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize in parallel
  await Future.wait([
    dotenv.load(),
    // Run consecutively.
    () async {
      await FMTCObjectBoxBackend().initialise();
      await const FMTCStore('forestPark').manage.create();
    }(),
    OfflineUploader().initialize()
  ]);

  runApp(UncontrolledProviderScope(
    container: providerContainer,
    child: const App(),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  // we listen to brightness changes (IE light to dark mode) and
  // rebuild the entire widget tree when it's changed
  // ignore: unused_field
  Brightness _brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = View.of(context).platformDispatcher.platformBrightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final lightTheme = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
      seedColor: kMaterialAppPrimaryColor,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
    ));
    final darkTheme = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
      seedColor: kMaterialAppPrimaryColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
    ));

    return MaterialApp(
      title: 'Trail Eyes',
      themeMode: ref.watch(settingsProvider.select((s) => s.colorTheme)).value,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: HomeScreen(key: homeKey),
    );
  }
}
