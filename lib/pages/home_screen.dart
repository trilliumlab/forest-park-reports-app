import 'package:flutter/material.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';

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
