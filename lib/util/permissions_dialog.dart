import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';

showMissingPermissionDialog(BuildContext context, String title, String message) {
  showPlatformDialog(
    context: context,
    builder: (context) => PlatformAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        PlatformDialogAction(
          child: PlatformText("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        PlatformDialogAction(
          child: PlatformText("Go To Settings"),
          onPressed: () {
            Geolocator.openAppSettings();
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}
