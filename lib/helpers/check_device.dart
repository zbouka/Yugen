import 'package:flutter/material.dart';

/// Simple way to get around and check if the current device is a phone or a tablet
bool get isTablet {
  final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalShortestSide =
      firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
  return logicalShortestSide > 550;
}
