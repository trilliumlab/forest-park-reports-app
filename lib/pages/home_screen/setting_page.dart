import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsApp extends StatefulWidget {
  @override
  _SettingsAppState createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  bool _isDarkModeEnabled = false;
  bool _isBackgroundGPSEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedMapQuality = 'Medium';
  String _selectedMode = 'Light';
  TargetPlatform _initialPlatform = TargetPlatform.android;

  dynamic getThemeData(BuildContext context, bool isDarkModeEnabled) {
    if (isMaterial(context)) {
      if (isDarkModeEnabled) {
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        );
      } else {
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
        );
      }
    } else if (isCupertino(context)) {
      return CupertinoThemeData(
        brightness: isDarkModeEnabled ? Brightness.dark : Brightness.light,
      );
    }
    return ThemeData.light();
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkModeEnabled = value;
      if (_isDarkModeEnabled) {
        _selectedMode = 'Dark';
      } else {
        _selectedMode = 'Light';
      }
    });
  }

  // Toggle Background GPS
  void _toggleBackgroundGPS(bool value) {
    setState(() {
      _isBackgroundGPSEnabled = value;
    });
  }

  // Update selected language
  void _updateLanguage(String value) {
    setState(() {
      _selectedLanguage = value;
    });
  }

  // Update selected map quality
  void _updateMapQuality(String value) {
    setState(() {
      _selectedMapQuality = value;
    });
  }

  // Get the name of the app theme based on platform
  String getAppThemeName() {
    return _initialPlatform == TargetPlatform.iOS ? 'iOS Theme' : 'Android Theme';
  }

  // Method to go back to the main page
  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      initialPlatform: _initialPlatform,
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getThemeData(context, _isDarkModeEnabled), // Use the theme based on _isDarkModeEnabled
          home: Material(
            child: PlatformScaffold(
              appBar: PlatformAppBar(
                title: Text('Settings'),
                leading: PlatformIconButton(
                  icon: Icon(context.platformIcons.back),
                  onPressed: () => _goBack(context),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    // App Theme
                    Text(
                      'App Theme: ${getAppThemeName()}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    // Platform selection
                    SizedBox(
                      width: double.infinity,
                      child: PlatformSegmentedControl<TargetPlatform>(
                        segments: [
                          PlatformSegment(
                            TargetPlatform.iOS,
                            Text('iOS'),
                          ),
                          PlatformSegment(
                            TargetPlatform.android,
                            Text('Android'),
                          ),
                        ],
                        selected: _initialPlatform,
                        onSelectionChanged: (value) {
                          setState(() {
                            _initialPlatform = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Dark Mode
                    DarkModeSwitch(
                      isDarkModeEnabled: _isDarkModeEnabled,
                      toggleDarkMode: _toggleDarkMode,
                    ),
                    SizedBox(height: 16.0),
                    // Background GPS
                    BackgroundGPSSwitch(
                      isBackgroundGPSEnabled: _isBackgroundGPSEnabled,
                      toggleBackgroundGPS: _toggleBackgroundGPS,
                    ),
                    SizedBox(height: 16.0),
                    // Language
                    //LanguageSelection(
                     // selectedLanguage: _selectedLanguage,
                      //updateLanguage: _updateLanguage,
                    //),
                    //SizedBox(height: 16.0),
                    // Selected Mode
                    SelectedMode(
                      selectedMode: _selectedMode,
                    ),
                    SizedBox(height: 16.0),
                    // Map Quality
                    MapQualitySelection(
                      selectedMapQuality: _selectedMapQuality,
                      updateMapQuality: _updateMapQuality,
                    ),
                    SizedBox(height: 16.0),
                    // About section
                    SizedBox(height: 16.0),
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'This app is built with the support of Portland State University and the National Science Foundation.',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class PlatformSegmentedControl<T> extends StatelessWidget {
  final List<PlatformSegment<T>> segments;
  final T? selected;
  final void Function(T? selected) onSelectionChanged;

  const PlatformSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) {
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton(
            segments: [
              for (final segment in segments)
                ButtonSegment(
                  value: segment.value,
                  label: segment.child,
                ),
            ],
            emptySelectionAllowed: true,
            onSelectionChanged: (selected) => onSelectionChanged(selected.first),
            selected: {
              if (selected != null)
                selected,
            },
          ),
        );
      },
      cupertino: (context, platform) {
        return CupertinoSlidingSegmentedControl<T>(
          onValueChanged: onSelectionChanged,
          groupValue: selected,
          children: {
            for (final segment in segments)
              segment.value: segment.child,
          },
        );
      },
    );
  }
}

class PlatformSegment<T> {
  final T value;
  final Widget child;
  const PlatformSegment(this.value, this.child);
}

class DarkModeSwitch extends StatelessWidget {
  final bool isDarkModeEnabled;
  final Function(bool) toggleDarkMode;

  const DarkModeSwitch({
    Key? key,
    required this.isDarkModeEnabled,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Dark Mode'),
      trailing: PlatformSwitch(
        value: isDarkModeEnabled,
        onChanged: toggleDarkMode,
      ),
    );
  }
}

class BackgroundGPSSwitch extends StatelessWidget {
  final bool isBackgroundGPSEnabled;
  final Function(bool) toggleBackgroundGPS;

  const BackgroundGPSSwitch({
    Key? key,
    required this.isBackgroundGPSEnabled,
    required this.toggleBackgroundGPS,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isBackgroundGPSEnabled) {
      FollowOnLocationUpdate.never;
    } else{
      FollowOnLocationUpdate.always;
    }

    // Default behavior when background GPS is enabled
    return ListTile(
      title: Text('Background GPS'),
      trailing: PlatformSwitch(
        value: isBackgroundGPSEnabled,
        onChanged: toggleBackgroundGPS,
      ),
    );
  }
}


class LanguageSelection extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;

  const LanguageSelection({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: Text('Language'),
      subtitle: Text(selectedLanguage),
      onTap: () {
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // English
                PlatformListTile(
                  title: Text('English'),
                  onTap: () {
                    updateLanguage('English');
                    Navigator.pop(context);
                  },
                ),
                // Spanish
                PlatformListTile(
                  title: Text('Spanish'),
                  onTap: () {
                    updateLanguage('Spanish');
                    Navigator.pop(context);
                  },
                ),
                // French
                PlatformListTile(
                  title: Text('French'),
                  onTap: () {
                    updateLanguage('French');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppSettings with ChangeNotifier {
  bool _isDarkModeEnabled = false;

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  void setDarkMode(bool value) {
    _isDarkModeEnabled = value;
    notifyListeners();
  }
}

class SelectedMode extends StatelessWidget {
  final String selectedMode;

  const SelectedMode({
    Key? key,
    required this.selectedMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Selected Mode: $selectedMode',
      style: TextStyle(fontSize: 18.0),
    );
  }
}

class MapQualitySelection extends StatelessWidget {
  final String selectedMapQuality;
  final Function(String) updateMapQuality;

  const MapQualitySelection({
    Key? key,
    required this.selectedMapQuality,
    required this.updateMapQuality,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Map Quality'),
      subtitle: Text(selectedMapQuality),
      onTap: () {
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text('Select Map Quality'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Low
                PlatformListTile(
                  title: Text('Low'),
                  onTap: () {
                    updateMapQuality('Low');
                    Navigator.pop(context);
                  },
                ),
                // Medium
                PlatformListTile(
                  title: Text('Medium'),
                  onTap: () {
                    updateMapQuality('Medium');
                    Navigator.pop(context);
                  },
                ),
                // High
                PlatformListTile(
                  title: Text('High'),
                  onTap: () {
                    updateMapQuality('High');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}