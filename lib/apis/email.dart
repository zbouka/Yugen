import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:yugen/env/env.dart';

/// Method to send an error email to the support team
/// It takes [dialog] to check if sending the email or not with a modal dialog
/// Then it takes [title] for the subject of the email and [error] for the body
Future<void> sendErrorMail(bool dialog, String title, Object error) async {
  final message = Email(
      subject: title,
      body: error.toString(),
      isHTML: false,
      recipients: [Env.supportEmail]);

  try {
    if (dialog) {
      Get.defaultDialog(
          title: "error".tr,
          middleText: "detailError".tr,
          cancel: TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("cancel".tr)),
          confirm: TextButton(
            onPressed: () async {
              await FlutterEmailSender.send(message);
              Get.back();
            },
            child: const Text("Ok"),
          ));
    } else {
      await FlutterEmailSender.send(message);
    }
  } on Exception {
    throw Exception("Email was not delivered");
  }
}
