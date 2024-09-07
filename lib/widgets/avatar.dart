import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:yugen/screens/main/preferences.dart';

import '../screens/auth/auth.dart';

/// A widget that shows the profilepic with some modifications
Widget getAvatar(
    double radius, double radius2, Color color, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Get.to(() => const Material(child: UserPreferences()));
    },
    child: CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: CircleAvatar(
        radius: MediaQuery.of(context).orientation == Orientation.landscape
            ? radius2 - 7
            : radius2,
        backgroundImage: NetworkImage(Auth().getUser()!.photoURL!),
      ),
    ),
  );
}
