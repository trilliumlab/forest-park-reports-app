import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/pages/home_screen.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        var theme = ThemeData.light().copyWith(
          colorScheme: lightDynamic ?? ThemeData.light().colorScheme.copyWith(
            background: Colors.grey.shade100,
            onBackground: Colors.grey.shade800,
          ),
          useMaterial3: true,
        );
        var darkTheme = ThemeData.dark().copyWith(
          colorScheme: darkDynamic ?? ThemeData.dark().colorScheme.copyWith(
            background: Colors.grey.shade900,
            onBackground: Colors.grey.shade100,
          ),
          useMaterial3: true,
        );
        return MaterialApp(
          title: 'Forest Park Reports',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
