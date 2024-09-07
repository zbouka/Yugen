import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

import '../Settings/icon_style.dart';
import '../Settings/screen_util.dart';

class MySettingsItem extends StatelessWidget {
  final IconData icons;
  final IconStyle? iconStyle;
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color color;

  const MySettingsItem(
      {super.key,
      required this.icons,
      this.iconStyle,
      required this.title,
      this.titleStyle,
      this.subtitle = "",
      this.color = Colors.grey,
      this.subtitleStyle,
      this.trailing,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: (iconStyle != null && iconStyle!.withBackground!)
          ? Container(
              decoration: BoxDecoration(
                color: iconStyle!.backgroundColor,
                borderRadius: BorderRadius.circular(iconStyle!.borderRadius!),
              ),
              padding: const EdgeInsets.all(5),
              child: Icon(
                icons,
                size: SettingsScreenUtils.settingsGroupIconSize,
                color: iconStyle!.iconsColor,
              ),
            )
          : Icon(
              icons,
              size: SettingsScreenUtils.settingsGroupIconSize,
            ),
      title: Text(
        title,
        style: titleStyle ??
            TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenScaler().getTextSize(7.5),
            ),
        maxLines: 1,
      ),
      subtitle: Text(
        subtitle!,
        style: subtitleStyle ??
            TextStyle(
              color: color,
              fontSize: ScreenScaler().getTextSize(6.9),
            ),
        maxLines: 1,
      ),
      trailing: (trailing != null)
          ? trailing
          : const Icon(Icons.arrow_forward_ios_rounded),
    );
  }
}
