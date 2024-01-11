import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameSettings extends StatelessWidget {
  const GameSettings({super.key});

  static dynamic fetchedSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(3, 8, 29, 0.8),
          borderRadius: GlobalStyles.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsItem(gif: 'setting_1', settingKey: 'players'),
            _SettingsItem(gif: 'setting_0', settingKey: 'language'),
            _SettingsItem(gif: 'setting_2', settingKey: 'drawtime'),
            _SettingsItem(gif: 'setting_3', settingKey: 'rounds'),
            _SettingsItem(gif: 'setting_6', settingKey: 'word_mode'),
            _SettingsItem(gif: 'setting_4', settingKey: 'word_count'),
            _SettingsItem(gif: 'setting_5', settingKey: 'hints'),
          ],
        ));
  }
}

class _SettingsItem extends StatelessWidget {
  _SettingsItem({required this.gif, required this.settingKey, super.key}) {
    // (Game.inst as PrivateGame).settings[settingKey] =
    //     GameSettings.fetchedSettings[settingKey]['default'];
  }

  final String gif;
  final String settingKey;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items = [];
    var settings = GameSettings.fetchedSettings[settingKey];
    if (settings['list'] == null) {
      int max = settings['max'];
      int min = settings['min'];

      for (int i = min; i <= max; i++) {
        items.add(DropdownMenuItem(value: i, child: Text(i.toString())));
      }
    } else {
      for (dynamic e in settings['list']) {
        items.add(DropdownMenuItem(value: e, child: Text(e.toString())));
      }
    }
    return Row(
      children: [
        GifManager.inst.misc(gif).builder.initShadowedOrigin(),
        Text(settingKey.tr),
        const Spacer(),
        DropdownButtonHideUnderline(
            child: DropdownButton(
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
                // padding: const EdgeInsets.only(left: 7),
                // isExpanded: true,
                value: settings['default'],
                items: items,
                onChanged: (dynamic newOption) {}))
      ],
    );
  }
}
