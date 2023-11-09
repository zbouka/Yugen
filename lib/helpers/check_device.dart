import 'package:flutter/material.dart';

/// Simple way to get around and check if the current device is a phone or a tablet
bool isTablet(BuildContext context) {
  return MediaQueryData.fromView(View.of(context)).size.shortestSide > 550;
}
