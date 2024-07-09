import 'package:cd_mobile/generated/locales.g.dart';
import 'package:cd_mobile/models/game/game.dart';
import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/game/private_game.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameSettingsController extends GetxController {
  GameSettingsController() {
    isCovered = (!(MePlayer.inst.isOwner == true)).obs;
  }
  late RxBool isCovered;
}

class GameSettings extends StatelessWidget {
  GameSettings({super.key}) {
    controller = Get.put(GameSettingsController());
  }

  late final GameSettingsController controller;

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
                    _LanguageSettingItem(),
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
                          onTap: (Game.inst as PrivateGame).startGame,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xff53e237),
                              borderRadius: GlobalStyles.borderRadius,
                            ),
                            child: Text('start'.tr,
                                style: const TextStyle(
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
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(3, 8, 29, 0.4),
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

  static List<String> proceededWords = [];

  String? validator(String? value) {
    if (value == null) return '';

    var fetchedRules = GameSettings.fetchedOptions['custom_words_rules'];

    // check length per word
    var minCharPerWord = fetchedRules['min_char_per_word'];
    var maxCharPerWord = fetchedRules['max_char_per_word'];

    // check word count
    var words = value.split(',');

    List<String> specialCharsWords = [];
    List<String> invalidLengthWords = [];
    Map<String, String> duplicatedWords = {};
    Map<String, String> uniqueValidWords = {};

    // get only strings with [a-zA-Z] maybe space
    for (int i = 0; i < words.length; i++) {
      var noMultiSpacesWord = fixSpaces(words[i]);
      // check the string has special chars other than a-zA-Z and space
      if (noMultiSpacesWord.isEmpty) continue;

      if (hasInvalidCharacters(noMultiSpacesWord)) {
        specialCharsWords.add(noMultiSpacesWord);
      } else {
        // check duplication
        var key = noMultiSpacesWord.toLowerCase();
        if (uniqueValidWords.containsKey(key)) {
          duplicatedWords[noMultiSpacesWord.toLowerCase()] = noMultiSpacesWord;
        } else {
          // no duplication, check word length
          var charsCountOfWord = notSpaceCharsCount(noMultiSpacesWord);
          if (charsCountOfWord < minCharPerWord || charsCountOfWord > maxCharPerWord) {
            // invalid
            invalidLengthWords.add(noMultiSpacesWord);
          } else {
            // valid
            uniqueValidWords[key] = noMultiSpacesWord;
          }
        }
      }
    }

    if (uniqueValidWords.isEmpty) {
      return null;
    }

    String invalidationMsg = '';
    if (specialCharsWords.isNotEmpty) {
      invalidationMsg = "custom_words_input_validate_not_words"
          .trParams({'specialCharsWords': specialCharsWords.toString()});
    }

    if (invalidLengthWords.isNotEmpty) {
      var newMsg = 'custom_words_input_validate_invalid_word_length'.trParams({
        'invalidLengthWords': invalidLengthWords.toString(),
        'min_char_per_word': minCharPerWord.toString(),
        'max_char_per_word': maxCharPerWord.toString()
      });
      invalidationMsg = "${invalidationMsg.isEmpty ? '' : '$invalidationMsg\n'}$newMsg";
    }

    if (duplicatedWords.isNotEmpty) {
      var newMsg = "custom_words_input_validate_duplicated_words"
          .trParams({'duplicatedWords': duplicatedWords.values.toString()});
      invalidationMsg = "${invalidationMsg.isEmpty ? '' : '$invalidationMsg\n'}$newMsg";
    }

    if (invalidationMsg.isNotEmpty) {
      invalidationMsg = "\n${"custom_words_input_validate_ignore_title".tr}\n$invalidationMsg";
    }

    // check word count
    var minWords = fetchedRules['min_words'];
    if (uniqueValidWords.length < minWords) {
      var newMsg =
          'custom_words_input_validate_words_count'.trParams({'min_words': minWords.toString()});
      return "$newMsg$invalidationMsg";
    }

    proceededWords = uniqueValidWords.values.toList();

    return null;
  }

  int notSpaceCharsCount(String word) => word.length - ' '.allMatches(word).length;

  // Use the pattern to check if the input contains invalid characters
  bool hasInvalidCharacters(String input) => RegExp(r'[^a-zA-Z\s]').hasMatch(input);

  String fixSpaces(String str) => str.replaceAll(RegExp(r"\s+"), " ").trim();

  late final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    var fetchedRules = GameSettings.fetchedOptions['custom_words_rules'];
    var maxLength = fetchedRules['max_char'];
    return Obx(() {
      if (Get.find<GameSettingsController>().isCovered.value) {
        return Container(decoration: InputStyles.decoration);
      }
      return Container(
          decoration: InputStyles.decoration,
          child: Form(
              key: formKey,
              child: TextFormField(
                validator: validator,
                maxLength: maxLength,
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
    });
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({required this.gif, required this.settingKey});

  final String gif;
  final String settingKey;

  void changeSetting(dynamic value) => (Game.inst as PrivateGame).changeSettings(settingKey, value);

  dynamic getSetting() => (Game.inst as PrivateGame).settings[settingKey];

  DropdownMenuItem _menuItem(dynamic value) => DropdownMenuItem(
      value: value,
      child: Text(value is String ? value.tr : value.toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));

  List<DropdownMenuItem> getItems() {
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
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(children: [
      Expanded(
          flex: 55,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FittedBox(child: GifManager.inst.misc(gif).builder.initShadowedOrigin().doFreezeSize()),
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
              child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton(
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: InputStyles.color),
                      padding: const EdgeInsets.only(left: 7),
                      // isExpanded: true,
                      value: getSetting(),
                      items: getItems(),
                      onChanged: changeSetting)))))
    ]));
  }
}

// TODO: _UseCustomWordsOnlyCheckbox: HIGHLIGHT WHEN FOCUS, CUSTOMIZED CHECKED STATE DISPLAY
class _UseCustomWordsOnlyCheckbox extends StatelessWidget {
  const _UseCustomWordsOnlyCheckbox();

  RxMap<String, dynamic> gameSettings() => (Game.inst as PrivateGame).settings;
  @override
  Widget build(BuildContext context) {
    return Obx(() => Checkbox(
        // TODO: CHANGED FROM MATERIALSTATEPROPERTY TO THIS, TEST AGAIN
        fillColor: WidgetStateProperty.resolveWith((states) {
          // TODO: CHANGED FROM MATERIALSTATE TO THIS, TEST AGAIN
          if (states.contains(WidgetState.selected)) {
            return Colors.blue; // Set the background color when checked
          }
          return Colors.white; // Set the background color when unchecked
        }),
        value: gameSettings()['use_custom_words_only'],
        onChanged: (bool? value) {
          (Game.inst as PrivateGame).changeSettings('use_custom_words_only', value);
        }));
  }
}

class _LanguageSettingItem extends _SettingsItem {
  const _LanguageSettingItem() : super(gif: 'setting_0', settingKey: 'language');
  @override
  List<DropdownMenuItem> getItems() {
    List<DropdownMenuItem> items = [];
    var settings = GameSettings.fetchedOptions[settingKey];

    for (dynamic e in settings['list']) {
      items.add(_menuItem(e));
    }

    return items;
  }

  @override
  DropdownMenuItem _menuItem(dynamic value) => DropdownMenuItem(
      value: value,
      child: Text(AppTranslation.translations[value]!['displayName']!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));

  @override
  void changeSetting(value) {
    super.changeSetting(value);
    var list = value!.split('_');
    Get.updateLocale(Locale(list[0], list[1]));
  }
}
