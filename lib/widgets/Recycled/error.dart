import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A special widget to show the error to the final user
class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;
  final bool? isError;
  final Icon? errorIcon;

  const CustomErrorWidget(
      {super.key, required this.errorMessage, this.isError, this.errorIcon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isError == false
              ? const Icon(
                  Icons.search,
                  color: Colors.red,
                  size: 50.0,
                )
              : errorIcon ??
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50.0,
                  ),
          const SizedBox(height: 10.0),
          Text(
            'errorScreen'.tr,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
