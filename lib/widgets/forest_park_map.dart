import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ForestParkMap extends ConsumerStatefulWidget {
  final bool followPointer;
  final ValueSetter<bool> onStickyUpdate;
  const ForestParkMap({
    Key? key,
    required this.followPointer,
    required this.onStickyUpdate,
  }) : super(key: key);

  @override
  ConsumerState<ForestParkMap> createState() => _ForestParkMapState();
}

class _ForestParkMapState extends ConsumerState<ForestParkMap> with WidgetsBindingObserver {
  final _location = Location();
  LocationData? _lastLoc;
  // TODO set initial camera position to be centered on ForestPark
  CameraPosition _lastCamera = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 12,
  );
  // we use a completer for the map controller so we can listen until
  // the map is loaded and the controller is set
  final Completer<GoogleMapController> _mapController = Completer();

  // TODO allow more map styles (custom styles?) + satellite
  late String _darkMapStyle;
  late String _lightMapStyle;

  // store last value of sticky location so we can know when it's changed
  // (then sticky button has been pressed)
  bool _lastStickyLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // listen for location changes and update _location
    _subscribeLocation();
    // load style jsons from assets
    _loadMapStyles();
    _setMapStyle();
  }

  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light.json');
  }

  // listen for brightness change so we can update map style
  @override
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  Future _setMapStyle() async {
    final controller = await _mapController.future;
    final theme = WidgetsBinding.instance.window.platformBrightness;
    if (theme == Brightness.dark) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(_lightMapStyle);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.future.then((c) => c.dispose());
    super.dispose();
  }

  void _subscribeLocation() {
    // runs on initial load, so update location and move camera without animation
    _location.getLocation().then((l) {
      _lastLoc = l;
      widget.onStickyUpdate(true);
      _lastCamera = CameraPosition(
          target: LatLng(l.latitude!, l.longitude!),
          zoom: 14.5
      );
      _mapController.future.then((c) {
        c.moveCamera(
            CameraUpdate.newCameraPosition(_lastCamera)
        );
      });
    });
    // sets up listener which runs whenever location changes
    _location.onLocationChanged.listen((l) {
      _lastLoc = l;
      if (widget.followPointer) {
        _animateCamera(LatLng(l.latitude!, l.longitude!));
      }
    });
  }

  // helper function to animate the camera to a target while retaining other camera info
  void _animateCamera(LatLng target) {
    _mapController.future.then((c) {
      c.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: target,
              zoom: _lastCamera.zoom,
              bearing: _lastCamera.bearing,
              tilt: _lastCamera.tilt
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // using ref.watch will allow the widget to be rebuilt everytime
    // the provider is updated
    ParkTrails parkTrails = ref.watch(parkTrailsProvider);
    // enable edge to edge mode on android
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: WidgetsBinding.instance.window.platformBrightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // if the sticky location button was just clicked, move camera
    if (widget.followPointer != _lastStickyLocation) {
      // the button was pressed
      _lastStickyLocation = widget.followPointer;
      if (widget.followPointer && _lastLoc != null) {
        // the button was pressed and it is now enabled
        _animateCamera(LatLng(_lastLoc!.latitude!, _lastLoc!.longitude!));
      }
    }

    // we use a listener to be able to detect when the map has been clicked as
    // the GoogleMap onCameraMove function does not differentiate moving
    // from a gesture, and moving the camera programmatically (_animateCamera)
    return Listener(
      onPointerDown: (e) {
        widget.onStickyUpdate(false);
      },
      child: GoogleMap(
        polylines: parkTrails.polylines,
        onMapCreated: _mapController.complete,
        initialCameraPosition: _lastCamera,
        mapType: MapType.normal,
        zoomControlsEnabled: false,
        compassEnabled: false,
        indoorViewEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onCameraMove: (camera) {
          _lastCamera = camera;
        },
        // the polylines take priority for taps, so this will
        // only be called when tapping outside a polyline
        onTap: (loc) {
          // we're using ref.read on the *notifier* because we want to call a
          // function on the notifier, not the provider, and we don't want
          // listen for any value changes as calling a function on a notifier
          // will update the provider and we already listen to the provider
          ref.read(parkTrailsProvider.notifier).deselectTrails();
        },
      ),
    );
  }

}
