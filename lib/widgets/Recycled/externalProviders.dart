import 'package:flutter/material.dart';

/// Simple widget to show the credits of the wallpapers and news
Widget madeBy(String provider, String image, {bool? isAsset}) {
  return Chip(
      backgroundColor: const Color(0xFFE1E4F3),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      avatar: CircleAvatar(
          radius: 20.0,
          child: isAsset == null ? Image.network(image) : Image.asset(image)),
      label: Text(
        provider,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3649AE)),
      ));
}
