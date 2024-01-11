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
            Expanded(
                flex: 52,
                child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SettingsItem(gif: 'setting_1', settingKey: 'players'),
                      const SizedBox(height: 3.5),
                      _SettingsItem(gif: 'setting_0', settingKey: 'language'),
                      const SizedBox(height: 3.5),
                      _SettingsItem(gif: 'setting_2', settingKey: 'drawtime'),
                      const SizedBox(height: 3.5),
                      _SettingsItem(gif: 'setting_3', settingKey: 'rounds'),
                      const SizedBox(height: 3.5),
                      _SettingsItem(gif: 'setting_6', settingKey: 'word_mode'),
                      const SizedBox(height: 3.5),
                      _SettingsItem(gif: 'setting_4', settingKey: 'word_count'),
                      const SizedBox(height: 3.5),
                      _SettingsItem(gif: 'setting_5', settingKey: 'hints'),
                    ])),
            Expanded(flex: 38, child: Container(color: Colors.white)),
            Expanded(flex: 10, child: Container(color: Colors.green))
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

  DropdownMenuItem _menuItem(dynamic value) => DropdownMenuItem(
      value: value, child: Text(value.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items = [];
    var settings = GameSettings.fetchedSettings[settingKey];
    if (settings['list'] == null) {
      int max = settings['max'];
      int min = settings['min'];

      for (int i = min; i <= max; i++) {
        items.add(_menuItem(i));
      }
    } else {
      for (dynamic e in settings['list']) {
        items.add(_menuItem(e));
      }
    }
    return Expanded(
        child: Row(
      children: [
        Expanded(
            flex: 55,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FittedBox(
                  child: GifManager.inst.misc(gif).builder.initShadowedOrigin().doFreezeSize()),
              const SizedBox(width: 7),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(settingKey.tr,
                      style: const TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)))
            ])),
        Expanded(
            flex: 45,
            child: Container(
                decoration: InputStyles.decoration,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
                        padding: const EdgeInsets.only(left: 7),
                        // isExpanded: true,
                        value: settings['default'],
                        items: items,
                        onChanged: (dynamic newOption) {}))))
      ],
    ));
  }
}
