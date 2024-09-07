import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/config/preferences.dart';
import 'package:path/path.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';
import 'package:yugen/helpers/user_exists.dart';
import '../../widgets/Recycled/permissions.dart';
import '../auth/auth.dart';

import 'package:file_picker/file_picker.dart';

class SettingsUI extends StatefulWidget {
  const SettingsUI({super.key});

  @override
  _SettingsUIState createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  bool showPassword = false;
  String path = "";
  bool edited = false;
  TextEditingController textEditingUserName =
      TextEditingController(text: Auth().getUser()!.displayName!);
  TextEditingController textEditingEmail =
      TextEditingController(text: Auth().getUser()!.email!);
  TextEditingController textEditingPassword = TextEditingController();

  /// Opens a FilePicker to choose a single picture
  Future<void> getProfilePic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      initialDirectory: "/storage/emulated/0/Downloads",
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      path = result.files.single.path!;
      setState(() {
        edited = true;
      });
    }
  }

  /// Checks if permissions are allowed and then executes the above method
  Future<void> getProfilePics() async {
    if (await getPermissionStatus(1) == true) {
      await getProfilePic();
    } else {
      if (await requestPermission(1) == true) {
        await getProfilePic();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.deepPurple),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "modify".tr,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: getCurrentColor(true)),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: const [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: edited == false
                                  ? NetworkImage(
                                      Auth().getUser()!.photoURL!,
                                    )
                                  : Image.file(File(path)).image)),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await getProfilePics();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 4,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              color: const Color.fromARGB(255, 82, 41, 152),
                            ),
                            child: const Icon(
                              Ionicons.pencil,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextField(
                  controller: textEditingUserName,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(12),
                    fontWeight: FontWeight.bold,
                    color: getCurrentColor(true),
                  ),
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Preferences().getThemeMode() == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.grey),
                      ),
                      // and:
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              style: BorderStyle.solid,
                              color: getCurrentColor(true))),
                      labelStyle: TextStyle(
                        color: getCurrentColor(true),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: getCurrentColor(true),
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "displayName".tr,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintStyle: TextStyle(
                        fontSize: scaler.getTextSize(12),
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextField(
                  controller: textEditingEmail,
                  style: TextStyle(
                    fontSize: scaler.getTextSize(12),
                    fontWeight: FontWeight.bold,
                    color: getCurrentColor(true),
                  ),
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Preferences().getThemeMode() == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.grey),
                      ),
                      // and:
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              style: BorderStyle.solid,
                              color: getCurrentColor(true))),
                      labelStyle: TextStyle(
                        color: getCurrentColor(true),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: getCurrentColor(true),
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "E-mail",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintStyle: TextStyle(
                        fontSize: scaler.getTextSize(12),
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Visibility(
                visible:
                    Auth().getUser()!.providerData[0].providerId == "password"
                        ? true
                        : false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35.0),
                  child: TextField(
                    obscureText: true,
                    controller: textEditingPassword,
                    style: TextStyle(
                      fontSize: scaler.getTextSize(12),
                      fontWeight: FontWeight.bold,
                      color: getCurrentColor(true),
                    ),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Preferences().getThemeMode() == ThemeMode.dark
                                      ? Colors.white
                                      : Colors.grey),
                        ),
                        // and:
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                style: BorderStyle.solid,
                                color: getCurrentColor(true))),
                        labelStyle: TextStyle(
                          color: getCurrentColor(true),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: getCurrentColor(true),
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 3),
                        labelText: "password".tr,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintStyle: TextStyle(
                          fontSize: scaler.getTextSize(11),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        side: const BorderSide(
                            width: 2, color: Colors.deepPurple),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "cancel".tr,
                        style: TextStyle(
                          fontSize: scaler.getTextSize(11),
                          letterSpacing: 2.2,
                          color: getCurrentColor(true),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Add space between the buttons
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () async {
                        await performAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "save".tr,
                        style: TextStyle(
                          fontSize: scaler.getTextSize(11),
                          letterSpacing: 2.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Uploads the selected image to FirebaseStorage, obtains the URL and then updates the profilepic
  /// It also deletes the previous pictures before the upload
  Future<void> uploadImage(String path) async {
    try {
      FirebaseStorage.instance
          .ref(Auth().getUser()!.uid)
          .listAll()
          .then((value) async {
        for (var element in value.items) {
          await FirebaseStorage.instance.ref(element.fullPath).delete();
        }
      });
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
    }
    Reference storageReference = FirebaseStorage.instance
        .ref(Auth().getUser()!.uid)
        .child(basename(path));

    await storageReference.putFile(File(path));

    return Auth()
        .getUser()!
        .updatePhotoURL(await storageReference.getDownloadURL());
  }

  /// This is the method where all changes are made into Firebase
  Future<void> performAction() async {
    try {
      if (path != "") {
        await uploadImage(path);
      }

      if (textEditingEmail.text != Auth().getUser()!.email! &&
          textEditingEmail.text.isNotEmpty) {
        await Auth().getUser()!.verifyBeforeUpdateEmail(textEditingEmail.text);
      }

      if (textEditingUserName.text.isNotEmpty &&
          await userExists(textEditingUserName.text, user: Auth().getUser()!) ==
              false) {
        await Auth().getUser()!.updateDisplayName(textEditingUserName.text);
      }

      if (textEditingPassword.text.isNotEmpty) {
        await Auth().getUser()!.updatePassword(textEditingPassword.text);
      }

      Get.back();
      if (Get.isSnackbarOpen == false) {
        Get.snackbar(
          "correct".tr,
          "updateProfile".tr,
          icon: const Icon(Ionicons.checkmark, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          borderRadius: 20,
          margin: const EdgeInsets.all(15),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          isDismissible: true,
          dismissDirection: DismissDirection.endToStart,
        );
      }
    } catch (e) {
      FirebaseAuthException error = e as FirebaseAuthException;

      if (error.code == "email-already-in-use" && Get.isSnackbarOpen == false) {
        Get.snackbar(
          "ERROR".tr,
          "errorUpdateProfileEmail".tr,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          borderRadius: 20,
          margin: const EdgeInsets.all(15),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          isDismissible: true,
          dismissDirection: DismissDirection.endToStart,
        );
      }
      if (error.code == "invalid-email" && Get.isSnackbarOpen == false) {
        Get.snackbar(
          "ERROR".tr,
          "invalidMail".tr,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          borderRadius: 20,
          margin: const EdgeInsets.all(15),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          isDismissible: true,
          dismissDirection: DismissDirection.endToStart,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      }
    }
  }
}
