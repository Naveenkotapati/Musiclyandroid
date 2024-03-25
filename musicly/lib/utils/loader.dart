import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:musicly/theme/theme.dart';

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.foldingCube
    ..indicatorColor = lightColorScheme.primary
    ..backgroundColor = Colors.white
    ..textColor = lightColorScheme.primary
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.black
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}