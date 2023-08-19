import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/models/camera_position.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

//const kApiUrl = "https://forestpark.elliotnash.org/api/v1";
//const kApiUrl = "https://forestpark-staging.elliotnash.org/api/v1";
//const kApiUrl = "http://192.168.0.102:8000/api/v1";
const kApiUrl = "http://localhost:8000/api/v1";

// This is for development only and needs to be set to null before a release
// TODO Maybe move this over to the settings page or only set on debug
const kPlatformOverride = null;
//const kPlatformOverride = TargetPlatform.iOS;

// 11:53 AM July 12 2022
final DateFormat kDisplayDateFormat = DateFormat('hh:mm a MMMM dd y');

const kNetworkEndian = Endian.little;

const kDbName = "forest_park_reports";

const double kIosStatusBarHeight = 50;
const double kFabPadding = 10;

const kHomeCameraPosition = CameraPosition(
  center: LatLng(45.57416784067063, -122.76892379502566),
  zoom: 11.5,
);

const kElevationMaxEntries = 100;

// encoding consts
const kElevationDeltaModifier = 4;
