import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/private_game.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameSettingsController extends GetxController {
  RxBool isCovered = false.obs;
}

class GameSettings extends StatelessWidget {
  GameSettings({super.key});

  final controller = Get.put(GameSettingsController());

  // DBRoomSettingsDocument
  static Map<String, dynamic> get fetchedOptions => (Game.inst as PrivateGame).options;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var content = Container(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                  flex: 52,
                  child: Column(children: [
                    _SettingsItem(gif: 'setting_1', settingKey: 'players'),
                    SizedBox(height: 3.5),
                    _SettingsItem(gif: 'setting_0', settingKey: 'language'),
                    SizedBox(height: 3.5),
                    _SettingsItem(gif: 'setting_2', settingKey: 'drawtime'),
                    SizedBox(height: 3.5),
                    _SettingsItem(gif: 'setting_3', settingKey: 'rounds'),
                    SizedBox(height: 3.5),
                    _SettingsItem(gif: 'setting_6', settingKey: 'word_mode'),
                    SizedBox(height: 3.5),
                    _SettingsItem(gif: 'setting_4', settingKey: 'word_count'),
                    SizedBox(height: 3.5),
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
                              const _UseCustomWordsOnlyCheckbox()
                            ],
                          ),
                          Expanded(child: CustomWordsInput())
                        ],
                      ))),
              Expanded(
                  flex: 10,
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          // onTap: (Game.inst as OwnedPrivateGame).startGame,
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

      return controller.isCovered.value
          ? Stack(
              children: [
                content,
                Container(
                  height: 600,
                  width: 800,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(3, 8, 29, 0.4),
                    borderRadius: GlobalStyles.borderRadius,
                  ),
                )
              ],
            )
          : content;
    });
  }
}

// TODO: _CustomWordsInput: HIGHLIGHT WHEN FOCUS
class CustomWordsInput extends StatelessWidget {
  CustomWordsInput({super.key}) {
    formKey = Get.put(GlobalKey<FormState>());
  }
  static String content = '';
  static List<String> proceededWords = [];

  String? validator(String? value) {
    content = value!;
    var fetchedRules = GameSettings.fetchedOptions['custom_words_rules'];

    var checkBoxName = 'use_custom_words_only'.tr;

    // check empty content
    if (value.isEmpty) {
      return 'custom_words_input_validate_empty_content'.trParams({'checkBoxName': checkBoxName});
    }

    // check word count
    var words = content.split(',');

    var minWords = fetchedRules['min_words'];
    if (words.length < minWords) {
      return 'custom_words_input_validate_words_count'.trParams({'min_words': minWords.toString()});
    }

    // check length per word
    var minCharPerWord = fetchedRules['min_char_per_word'];
    var maxCharPerWord = fetchedRules['max_char_per_word'];
    List<String> invalidWords = [];
    for (int i = 0; i < words.length; i++) {
      words[i] = words[i].trim();
      var word = words[i];
      if (word.length < minCharPerWord || word.length > maxCharPerWord) {
        invalidWords.add(word);
      }
    }
    if (invalidWords.isNotEmpty) {
      return 'custom_words_input_validate_word_length'.trParams({
        'invalidWords': invalidWords.toString(),
        'min_char_per_word': minCharPerWord.toString(),
        'max_char_per_word': maxCharPerWord.toString()
      });
    }

    proceededWords = words;

    return null;
  }

  late final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    var fetchedRules = GameSettings.fetchedOptions['custom_words_rules'];
    var maxLength = fetchedRules['max_char'];
    return Container(
        decoration: InputStyles.decoration,
        child: Form(
            key: formKey,
            child: TextFormField(
              validator: validator,
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
            )));
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({required this.gif, required this.settingKey});

  final String gif;
  final String settingKey;

  void changeSetting(dynamic value) => (Game.inst as PrivateGame).updateSettings(settingKey, value);

  dynamic getSetting() => (Game.inst as PrivateGame).settings[settingKey];

  DropdownMenuItem _menuItem(dynamic value) => DropdownMenuItem(
      value: value,
      child: Text(value is String ? value.tr : value.toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> items = [];
    var settings = GameSettings.fetchedOptions[settingKey];
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

// TODO: _UseCustomWordsOnlyCheckbox: HIGHLIGHT WHEN FOCUS, CUSTOMIZED CHECKED STATE DISPLAY
class _UseCustomWordsOnlyCheckbox extends StatelessWidget {
  const _UseCustomWordsOnlyCheckbox();

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
