import 'package:cd_mobile/models/game_play/game.dart';
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
                child: Column(children: [
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
            Expanded(
                flex: 38,
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('custom_words'.tr,
                                style: const TextStyle(
                                  fontSize: 16.8,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromRGBO(240, 240, 240, 1),
                                )),
                            const Spacer(),
                            Text('use_custom_words_only'.tr,
                                style: const TextStyle(
                                    fontSize: 13.44,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromRGBO(240, 240, 240, 1))),
                            _UseCustomWordsOnlyCheckbox()
                          ],
                        ),
                        const Expanded(child: _CustomWordsInput())
                      ],
                    ))),
            Expanded(
                flex: 10,
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () {
                          var privateGameSettings = (Game.inst as PrivateGame).settings;
                          if (privateGameSettings['use_custom_words_only']) {
                            privateGameSettings['custom_words'] =
                                _CustomWordsInput.contentIntoList();
                            privateGameSettings.remove('language');
                          }
                          //TODO: private game get started
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff53e237),
                            borderRadius: GlobalStyles.borderRadius,
                          ),
                          child: Text('start'.tr,
                              style: TextStyle(
                                  fontSize: 32,
                                  color: PanelStyles.textColor,
                                  fontWeight: FontWeight.w800,
                                  shadows: [GlobalStyles.textShadow])),
                        ))))
          ],
        ));
  }
}

// TODO: CUSTOMIZE _CUSTOMWORDSINPUT: HIGHLIGHT WHEN FOCUS, text formater to follow rules
class _CustomWordsInput extends StatelessWidget {
  const _CustomWordsInput();
  static String content = '';
  static List<String> contentIntoList() {
    // split by comma
    var rawList = content.split(',');
    // TODO: check each words

    return rawList;
  }

  @override
  Widget build(BuildContext context) {
    var fetchedRules = GameSettings.fetchedSettings['custom_words_rules'];
    var maxLength = fetchedRules['max_char'];
    return Container(
        decoration: InputStyles.decoration,
        child: TextField(
          maxLength: maxLength,
          onChanged: (value) => content = value,
          decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
              border: InputBorder.none,
              hintText: 'custom_words_input_placeholder'.trParams({
                'min_words': fetchedRules['min_words'].toString(),
                'min_char_per_word': fetchedRules['min_char_per_word'].toString(),
                'max_char_per_word': fetchedRules['max_char_per_word'].toString(),
                'max_char': maxLength.toString()
              }),
              hintStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  fontSize: 15.4)),
          maxLines: null,
        ));
  }
}

class _SettingsItem extends StatelessWidget {
  _SettingsItem({required this.gif, required this.settingKey}) {
    changeSetting(GameSettings.fetchedSettings[settingKey]['default']);
  }

  final String gif;
  final String settingKey;

  void changeSetting(dynamic value) => (Game.inst as PrivateGame).settings[settingKey] = value;

  dynamic getSetting() => (Game.inst as PrivateGame).settings[settingKey];

  DropdownMenuItem _menuItem(dynamic value) => DropdownMenuItem(
      value: value,
      child: Text(value.toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));

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
                child: StatefulBuilder(
                  builder: (ct, setState) {
                    return DropdownButtonHideUnderline(
                        child: DropdownButton(
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
                            padding: const EdgeInsets.only(left: 7),
                            // isExpanded: true,
                            value: getSetting(),
                            items: items,
                            onChanged: (value) => setState(() => changeSetting(value))));
                  },
                )))
      ],
    ));
  }
}

// TODO: CUSTOMIZES CHECKBOX: HIGHLIGHT WHEN FOCUS, CUSTOMIZED CHECKED STATE DISPLAY
class _UseCustomWordsOnlyCheckbox extends StatelessWidget {
  _UseCustomWordsOnlyCheckbox() {
    gameSettings()['use_custom_words_only'] = false;
  }

  dynamic gameSettings() => (Game.inst as PrivateGame).settings;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (ct, setState) {
      return Checkbox(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue; // Set the background color when checked
            }
            return Colors.white; // Set the background color when unchecked
          }),
          value: gameSettings()['use_custom_words_only'],
          onChanged: (bool? value) {
            setState(() => gameSettings()['use_custom_words_only'] = value);
          });
    });
  }
}
