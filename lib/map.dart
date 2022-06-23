import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forest_park_reports/trail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:location/location.dart';

class ForestParkMap extends StatefulWidget {
  final bool followPointer;
  final VoidCallback onFirstMove;
  const ForestParkMap({
    Key? key,
    required this.followPointer,
    required this.onFirstMove,
  }) : super(key: key);

  @override
  State<ForestParkMap> createState() => _ForestParkMapState();
}

class _ForestParkMapState extends State<ForestParkMap> {
  bool _firstLoad = true;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final _location = Location();
  LocationData? _lastLoc;
  CameraPosition _lastCamera = const CameraPosition(
    target: LatLng(45.527343, -122.727776),
    zoom: 14.5,
  );
  GoogleMapController? _mapController;

  bool _lastFollowPointer = true;

  List<Trail> trails = [];

  void _buildPolyline() {
    setState(() {
      for (final trail in trails) {
        _polylines.add(Polyline(
          polylineId: PolylineId(trail.name),
          visible: true,
          points: trail.path,
          width: 3,
          color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
        ));
      }
    });
  }

  void _subscribeLocation() {
    _location.onLocationChanged.listen((l) {
      _lastLoc = l;
      if (widget.followPointer && _mapController != null) {
        _animateCamera(LatLng(l.latitude!, l.longitude!));
      }
    });
  }

  void _animateCamera(LatLng target) {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: target,
            zoom: _lastCamera.zoom,
            bearing: _lastCamera.bearing,
            tilt: _lastCamera.tilt
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // enable edge to edge mode on android
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (_firstLoad) {
      _firstLoad = false;
      _subscribeLocation();
      _loadGpx(context);
    }

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
        widget.onFirstMove();
      },
      child: GoogleMap(
        polylines: _polylines,
        markers: _markers,
        onMapCreated: _onMapCreated,
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

  void _onMapCreated(GoogleMapController controllerParam) {
    _mapController = controllerParam;
    if (trails.isNotEmpty) {
      _buildPolyline();
    }
  }

  Future _loadGpx(BuildContext context) async {
    // get file path of all gpx files in asset folder
    final bundle = DefaultAssetBundle.of(context);
    final manifestContent = await bundle.loadString('AssetManifest.json');
    List<String> pathPaths = json.decode(manifestContent).keys
        .where((String key) => key.contains('.gpx')).toList();

    // TODO proper trail class
    for (var path in pathPaths) {
      path = Uri.decodeFull(path);
      trails.add(Trail(
          path.split("/")[1],
          GpxReader().fromString(await bundle.loadString(path))
      ));
    }

    if (_mapController != null) {
      _buildPolyline();
    }
  }

}
