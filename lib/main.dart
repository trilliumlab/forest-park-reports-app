import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/map.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool stickyLocation = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestParkMap(
        followPointer: stickyLocation,
        onStickyUpdate: (val) {
          setState(() {
            stickyLocation = val;
          });
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.background,
        onPressed: () {
          setState(() {
            stickyLocation = !stickyLocation;
          });
        },
        child: Icon(
            Icons.my_location_rounded,
            color: stickyLocation
                ? theme.colorScheme.primary
                : theme.colorScheme.onBackground
        ),
      ),
    );
  }
}
