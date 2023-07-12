import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forest_park_reports/consts.dart';

class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: kIosStatusBarHeight,
          ),
        ),
      ),
    );
  }
}
