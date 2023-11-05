import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/assets/loading.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/screens/main/settings.dart';
import 'package:yugen/widgets/Preferences/usercard.dart';

import '../../widgets/Preferences/settingsgroup.dart';
import '../../widgets/Preferences/settingsitem.dart';
import '../../widgets/Recycled/get_color.dart';
import '../../widgets/Settings/icon_style.dart';
import '../../widgets/Settings/settings_item.dart';
import '../welcome/changeLanguage.dart';

/// Screen used for changing/viewing the preferences
class UserPreferences extends StatefulWidget {
  const UserPreferences({super.key});

  @override
  State<UserPreferences> createState() => _UserPreferencesState();
}

class _UserPreferencesState extends State<UserPreferences> {
  bool loading = false;
  late PackageInfo packageInfo;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) => packageInfo = value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(color: getCurrentColor(false), child: const Loading())
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(
                  bottom: 20, left: 10, right: 10, top: 10),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  /// User card that shows the username and
                  UserCard(
                    cardColor: Colors.red,
                    userName: Auth().getUser() != null
                        ? Auth().getUser()!.displayName
                        : null,
                    cardActionWidget: MySettingsItem(
                      icons: Icons.edit,
                      titleStyle: const TextStyle(color: Colors.white),
                      iconStyle: IconStyle(
                        withBackground: true,
                        borderRadius: 50,
                        backgroundColor: Colors.yellow[600],
                      ),
                      title: "modify".tr,
                      color: Colors.white,
                      subtitle: "tapToChange".tr,
                      onTap: () {
                        Get.to(() => const SettingsUI());
                      },
                    ),
                  ),

                  /// We do 2 things here: First we show an option to change the language (Spanish and English) for now
                  /// And the other thing is to change the current theme option in case the user wants
                  GroupSettings(
                    items: [
                      SettingsItem(
                        onTap: () {
                          showDialogue(context);
                        },
                        icons: Icons.language_rounded,
                        iconStyle: IconStyle(),
                        title: 'language'.tr,
                        subtitle: "changeLanguage".tr,
                      ),
                      SettingsItem(
                        onTap: () {},
                        icons: Icons.dark_mode_rounded,
                        iconStyle: IconStyle(
                          withBackground: true,
                          backgroundColor: Colors.yellow,
                        ),
                        title: 'changeMode'.tr,
                        subtitle: "changeTheme".tr,
                        trailing: Switch.adaptive(
                          value: Preferences().getThemeMode() == ThemeMode.dark
                              ? true
                              : false,
                          onChanged: (value) {
                            Preferences().changeThemeMode();
                          },
                        ),
                      ),

                      /// Here it shows an informative dialog about our app
                      SettingsItem(
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: packageInfo.appName,
                            applicationVersion: packageInfo.version,
                            children: <Widget>[
                              const SizedBox(
                                height: 20,
                              ),
                              Text("descriptionYugen".tr),
                              const SizedBox(
                                height: 10,
                              ),
                              Text("descriptionYugen2".tr)
                            ],
                            applicationIcon: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(20), // Image border
                              child: SizedBox.fromSize(
                                size: const Size.fromRadius(48), // Image radius
                                child: Image.asset(
                                  "lib/assets/icono.jpg",
                                  height: 100,
                                  width: 100,
                                ),
                              ),
                            ),
                          );
                        },
                        icons: Icons.info_rounded,
                        iconStyle: IconStyle(
                          backgroundColor: Colors.purple,
                        ),
                        title: 'about'.tr,
                        subtitle: "learnMore".tr,
                      ),

                      /// Simple log out action in case the current user is not null
                      SettingsItem(
                          icons: Icons.exit_to_app_rounded,
                          title: "signOut".tr,
                          onTap: () {
                            if (Auth().getUser() != null) {
                              FutureBuilder<dynamic>(
                                future: Auth().signOut(),
                                builder: (BuildContext context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Loading();
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            } else {
                              return;
                            }
                          }),
                      //Here we try to delete the user, in case something failed we just send an error mail
                      SettingsItem(
                        onTap: () async {
                          Get.defaultDialog(
                            confirm: TextButton(
                                onPressed: () async {
                                  Get.back();
                                  if (mounted) {
                                    setState(() {
                                      loading = true;
                                    });
                                  }

                                  try {
                                    dynamic result = await Auth().deleteUser();
                                    if (result == null) {
                                      if (mounted) {
                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    sendErrorMail(true, "ERROR", e);
                                  }
                                },
                                child: Text("confirm".tr)),
                            cancel: TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text("cancel".tr)),
                            title: "deleteAccount".tr,
                            middleText: "confirmDeleteAccount".tr,
                          );
                        },
                        icons: Icons.delete,
                        title: "deleteAccount".tr,
                        titleStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
