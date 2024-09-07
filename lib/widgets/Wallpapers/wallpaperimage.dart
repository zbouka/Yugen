import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yugen/config/preferences.dart';

import '../../apis/email.dart';
import 'package:wallpaper/wallpaper.dart';

import '../Recycled/screen_enum.dart';

/// Class to show the wallpaper image allowing to set the wallpapers choosing between 3 options (Lock Screen, Home Screen or both)
class WallpaperImage extends StatefulWidget {
  const WallpaperImage({super.key, required this.image});
  final String image;

  @override
  State<WallpaperImage> createState() => _WallpaperImageState();
}

class _WallpaperImageState extends State<WallpaperImage> {
  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  /// The method applies the wallpaper to the selected screen.
  /// In this case, we don't need to check permissions because it saves the image in a temporary directory (cache directory in Android),
  /// which can be cleared at any time.
  /// Since we don't need the wallpaper after applying it, we won't be concerned about that at all
  Future<void> applyWallpaper(String url, Screen type) async {
    try {
      String progressString = "";
      Dio dio = Dio();

      var dir = await getTemporaryDirectory();
      await dio.download(url, "${dir.path}/myimage.jpeg",
          onReceiveProgress: (rec, total) async {
        progressString = "${((rec / total) * 100).toStringAsFixed(0)}%";

        type == Screen.HOME && progressString == "100%"
            ? await Wallpaper.homeScreen(
                location: DownloadLocation.temporaryDirectory,
                imageName: "myimage")
            : type == Screen.LOCK && progressString == "100%"
                ? await Wallpaper.lockScreen(
                    location: DownloadLocation.temporaryDirectory,
                    imageName: "myimage")
                : type == Screen.BOTH && progressString == "100%"
                    ? await Wallpaper.bothScreen(
                        location: DownloadLocation.temporaryDirectory,
                        imageName: "myimage")
                    : null;

        Get.back();
        if (!Get.isSnackbarOpen) {
          Get.snackbar("success".tr, "successWallpaper".tr);
        }
      });

      // await dispose();
    } catch (error) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar("Error", 'detailError'.tr);
      }
      sendErrorMail(true, "ERROR WALLPAPER", error);
    }
  }

  /// Shows a special dialog in case we have android 12+
  /// This is done in order to that having the Dynamic Color activated can cause the app to break and restart
  /// which can bother the final user
  /// It just triggers one time
  Future<void> checkDynamicColor() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt > 30 && !Preferences().wasDialogOpened()) {
      Get.defaultDialog(
        title: "warningDynamic".tr,
        middleText: "dynamic".tr,
        confirm: TextButton(
            onPressed: () async {
              Get.back();
            },
            child: Text("confirm".tr)),
      );
      Preferences().setDialogOpen();
    }
  }

  @override
  void initState() {
    super.initState();
    checkDynamicColor().then((value) => null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: <Widget>[
      Image.network(
        widget.image,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          //setState() not needed, because the widget doesn´t even build

          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        },
      ),
      OverflowBar(
        alignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton.filledTonal(
            onPressed: () async {
              await applyWallpaper(widget.image, Screen.HOME);
            },
            icon: const Icon(Icons.home),
          ),
          IconButton.filledTonal(
              onPressed: () async {
                await applyWallpaper(widget.image, Screen.LOCK);
              },
              icon: const Icon(Icons.lock)),
          IconButton.filledTonal(
            onPressed: () async {
              await applyWallpaper(widget.image, Screen.BOTH);
            },
            icon: const Icon(Icons.phone_android),
          ),
        ],
      )
    ]);
  }
}
