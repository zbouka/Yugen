import 'package:flutter/material.dart';

import '../Settings/screen_util.dart';
import '../Settings/settings_item.dart';

/// This widget was extracted from a widget that i couldn´t use because of the dependences
/// so in order to use it, i had to copy it in my code.
/// Source babstrap_settings_screen
class GroupSettings extends StatelessWidget {
  final String? _settingsGroupTitle;
  final TextStyle? _groupSettingsTitleStyle;
  final List<SettingsItem> _items;
  // Icons size
  final double? _iconItemSize;

  const GroupSettings(
      {super.key,
      String? settingsGroupTitle,
      TextStyle? groupSettingsTitleStyle,
      required List<SettingsItem> items,
      double? iconItemSize = 25})
      : _iconItemSize = iconItemSize,
        _items = items,
        _groupSettingsTitleStyle = groupSettingsTitleStyle,
        _settingsGroupTitle = settingsGroupTitle;

  @override
  Widget build(BuildContext context) {
    if (_iconItemSize != null) {
      SettingsScreenUtils.settingsGroupIconSize = _iconItemSize;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The title
          (_settingsGroupTitle != null)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    _settingsGroupTitle!,
                    style: (_groupSettingsTitleStyle == null)
                        ? const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)
                        : _groupSettingsTitleStyle,
                  ),
                )
              : Container(),
          // The GroupSettings sections
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return _items[index];
              },
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }
}
