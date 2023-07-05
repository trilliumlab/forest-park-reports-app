import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

const kApiUrl = "https://forestpark.elliotnash.org/api/v1";
//const kApiUrl = "http://192.168.0.102:8000/api/v1";

// This is for development only and needs to be set to null before a release
// TODO Maybe move this over to the settings page
const kPlatformOverride = null;

// 11:53 AM July 12 2022
final DateFormat kDisplayDateFormat = DateFormat('hh:mm a MMMM dd y');

const kNetworkEndian = Endian.little;

const kDbName = "forest_park_reports";
