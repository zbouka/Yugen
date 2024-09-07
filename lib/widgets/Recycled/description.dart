import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

/// Description of the manga or anime
class Desc extends StatelessWidget {
  final String img, status, title, year, description;

  const Desc({
    super.key,
    required this.img,
    required this.status,
    required this.title,
    required this.year,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
                child: Center(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? ScreenScaler().getTextSize(9)
                      : 18,
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }
}
