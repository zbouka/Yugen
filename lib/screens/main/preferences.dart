import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/assets/loading.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/auth.dart';
import 'package:yugen/screens/main/settings.dart';
import 'package:yugen/widgets/Preferences/usercard.dart';
import 'package:yugen/widgets/Preferences/settingsgroup.dart';
import 'package:yugen/widgets/Preferences/settingsitem.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';
import 'package:yugen/widgets/Settings/icon_style.dart';
import 'package:yugen/widgets/Settings/settings_item.dart';
import '../welcome/changeLanguage.dart';

/// Screen used for changing/viewing the preferences
class UserPreferences extends StatefulWidget {
  const UserPreferences({super.key});

  @override
  _UserPreferencesState createState() => _UserPreferencesState();
}

class _UserPreferencesState extends State<UserPreferences> {
  bool _loading = false;
  late PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleSignOut() async {
    await Auth().signOut();
    if (mounted) {
      setState(() {});
    }
  }

  void _showDeleteAccountDialog() {
    Get.defaultDialog(
      confirm: TextButton(
        onPressed: () async {
          Get.back();
          setState(() {
            _loading = true;
          });

          try {
            await Auth().deleteUser();
          } catch (e) {
            sendErrorMail(true, "ERROR", e);
          } finally {
            if (mounted) {
              setState(() {
                _loading = false;
              });
            }
          }
        },
        child: Text("confirm".tr),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("cancel".tr),
      ),
      title: "deleteAccount".tr,
      middleText: "confirmDeleteAccount".tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Container(
            color: getCurrentColor(false),
            child: const Loading(),
          )
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  UserCard(
                    cardColor: Colors.red,
                    userName: Auth().getUser()?.displayName,
                    cardActionWidget: MySettingsItem(
                      icons: Icons.edit,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenScaler().getTextSize(7.5),
                      ),
                      iconStyle: IconStyle(
                        withBackground: true,
                        borderRadius: 50,
                        backgroundColor: Colors.yellow[600],
                      ),
                      title: "modify".tr,
                      color: Colors.white,
                      subtitle: "tapToChange".tr,
                      onTap: () => Get.to(() => const SettingsUI()),
                    ),
                  ),
                  GroupSettings(
                    items: [
                      SettingsItem(
                        onTap: () => showDialogue(context),
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
                          value: Preferences().getThemeMode() == ThemeMode.dark,
                          onChanged: (value) {
                            Preferences().changeThemeMode();
                          },
                        ),
                      ),
                      SettingsItem(
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: _packageInfo.appName,
                            applicationVersion: _packageInfo.version,
                            children: <Widget>[
                              const SizedBox(height: 20),
                              Text("descriptionYugen".tr),
                              const SizedBox(height: 10),
                              Text("descriptionYugen2".tr),
                            ],
                            applicationIcon: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox.fromSize(
                                size: const Size.fromRadius(48),
                                child: Image.asset("lib/assets/icono.jpg"),
                              ),
                            ),
                          );
                        },
                        icons: Icons.info_rounded,
                        iconStyle: IconStyle(backgroundColor: Colors.purple),
                        title: 'about'.tr,
                        subtitle: "learnMore".tr,
                      ),
                      SettingsItem(
                        icons: Icons.exit_to_app_rounded,
                        title: "signOut".tr,
                        onTap: () {
                          if (Auth().getUser() != null) {
                            _handleSignOut();
                          }
                        },
                      ),
                      SettingsItem(
                        onTap: _showDeleteAccountDialog,
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
