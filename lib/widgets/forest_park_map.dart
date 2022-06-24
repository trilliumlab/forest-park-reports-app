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
  CameraPosition _lastCamera = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 12,
  );
  final Completer<GoogleMapController> _mapController = Completer();

  late String _darkMapStyle;
  late String _lightMapStyle;

  bool _lastFollowPointer = true;

  List<Trail> trails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscribeLocation();
    _loadMapStyles();
    _setMapStyle();
  }

  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light.json');
  }

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
    _location.onLocationChanged.listen((l) {
      _lastLoc = l;
      if (widget.followPointer) {
        _animateCamera(LatLng(l.latitude!, l.longitude!));
      }
    });
  }

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
    ParkTrails parkTrails = ref.watch(parkTrailsProvider);
    // enable edge to edge mode on android
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: WidgetsBinding.instance.window.platformBrightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // if the sticky location button was just clicked, move camera
    //TODO should probably be using some state management
    if (widget.followPointer != _lastFollowPointer) {
      // the button was pressed
      _lastFollowPointer = widget.followPointer;
      if (widget.followPointer && _lastLoc != null) {
        // the button was pressed and it is now enabled
        _animateCamera(LatLng(_lastLoc!.latitude!, _lastLoc!.longitude!));
      }
    }

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
      ),
    );
  }

}
