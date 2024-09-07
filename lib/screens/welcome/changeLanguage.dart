import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/preferences.dart';
import 'package:yugen/config/lang/language_list.dart';

/// Method to change locale using get plugin to the [locale]
void changeLanguage(Locale locale) {
  Get.updateLocale(locale);
  Preferences().saveLocale(locale.languageCode);
  Get.back();
}

/// Shows a dialogue to apply the locale picked using the above method
void showDialogue(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Text('choose'.tr),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(locales[index]['name'] as String),
                  ),
                  onTap: () {
                    changeLanguage(locales[index]['locale'] as Locale);
                  },
                ),
            separatorBuilder: (context, index) => const Divider(
                  color: Colors.black,
                ),
            itemCount: locales.length),
      ),
    ),
  );
}
