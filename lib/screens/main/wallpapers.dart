import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yugen/config/preferences.dart';
import 'package:ionicons/ionicons.dart';
import 'package:yugen/apis/api_wallpaper.dart';
import 'package:yugen/helpers/check_device.dart';
import 'package:yugen/widgets/Recycled/externalProviders.dart';
import 'package:yugen/widgets/Wallpapers/wallpaperimage.dart';

import '../../assets/loading.dart';
import '../../config/themes/themes.dart';
import '../../models/wallpaper.dart';
import '../../apis/email.dart';
import '../../widgets/Recycled/error.dart';

/// Screen that shows wallpapers for both phones and tablets using the wallpapers API
class Wallpapers extends StatefulWidget {
  const Wallpapers({super.key});

  @override
  State<Wallpapers> createState() => _WallpapersState();
}

class _WallpapersState extends State<Wallpapers> {
  String progressString = "";

  int value = 0;
  bool isPressed = false;
  Object? miError;
  bool work = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("YugenWallpapers",
              style: TextStyle(
                  fontSize: 30, fontFamily: GoogleFonts.playball().fontFamily)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: isPressed
                  ? const Icon(Ionicons.tablet_landscape,
                      color: Colors.deepPurple)
                  : const Icon(Ionicons.phone_portrait,
                      color: Colors.deepPurple),
              onPressed: () {
                setState(() {
                  isPressed = !isPressed;
                });
              },
            ),
          ]),
      body: SafeArea(
        child: FutureBuilder<List<Wallpaper>>(
          future: isPressed
              ? ApiServiceWallpaper().getWallpapers(true)
              : ApiServiceWallpaper().getWallpapers(false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            } else if (snapshot.data!.isEmpty) {
              return SizedBox(
                width: Get.size.width,
                child: CustomErrorWidget(
                  errorMessage: "noWallpapers".tr,
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    madeBy("xtrafondo".tr, "lib/assets/xtrafondos.png",
                        isAsset: true),
                    GridView.builder(
                      cacheExtent: 1000.0,
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 10,
                        right: 10,
                        bottom: 60,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => Material(
                        color: Preferences().getThemeMode() == ThemeMode.dark
                            ? Themes().darkTheme.scaffoldBackgroundColor
                            : Themes().lightTheme.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => WallpaperImage(
                                image: snapshot.data![index].wallpaper));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: AspectRatio(
                                    aspectRatio:
                                        isTablet ? 3.0 / 2.0 : 2.0 / 3.0,
                                    child: ExtendedImage.network(
                                      snapshot.data![index].wallpaper,
                                      clearMemoryCacheWhenDispose: true,
                                      clearMemoryCacheIfFailed: true,
                                      cacheWidth: 200 *
                                          View.of(context)
                                              .devicePixelRatio
                                              .ceil(),

                                      loadStateChanged: (state) {
                                        switch (state.extendedImageLoadState) {
                                          case LoadState.loading:
                                            return const Loading();

                                          case LoadState.failed:
                                            return GestureDetector(
                                              child: const Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onTap: () => Get.defaultDialog(
                                                  title: "error".tr,
                                                  middleText: "detailError".tr,
                                                  cancel: TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text("cancel".tr)),
                                                  confirm: TextButton(
                                                    onPressed: () {
                                                      sendErrorMail(
                                                          true,
                                                          "WALLPAPER ERROR",
                                                          miError!);
                                                      Get.back();
                                                    },
                                                    child: const Text("Ok"),
                                                  )),
                                            );
                                          case LoadState.completed:
                                            return null;
                                        }
                                      },
                                      fit: BoxFit.cover,
                                      cache: true, // store in cache
                                      enableMemoryCache:
                                          false, // do not store in memory
                                      enableLoadState: false, // hide spinner
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                  snapshot.data![index].resolution
                                      .toString()
                                      .trim(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 256,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
