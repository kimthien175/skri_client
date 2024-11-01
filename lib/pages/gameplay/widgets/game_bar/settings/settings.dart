import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/slider.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../../../../../models/models.dart';
import 'key_binding.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  static final settingDialog = GameDialog(
      title: () => 'Settings'.tr,
      content: SizedBox(
          width: 500,
          child: Column(children: [
            Obx(() => _TittleItem(
                icon: 'audio', title: "${'Volume'.tr} ${SystemSettings.inst.volumeToString}%")),
            const SettingsSlider(),
            //
            const SizedBox(height: 15),
            //
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _TittleItem(title: "Hotkeys".tr, icon: 'key'),
              AnimatedButton(
                onTap: SystemSettings.inst.resetKeyMaps,
                decorators: [
                  const AnimatedButtonBackgroundColorDecorator(),
                  AnimatedButtonTooltipDecorator(
                      childBuilder: (tag) => Text('reset_hotkeys_tooltip'.tr))
                ],
                child: Text('Reset'.tr),
              )
            ]),
            Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: (SystemSettings.inst.keyMaps.entries.toList()
                      ..sort((a, b) => a.value.order.compareTo(b.value.order)))
                    .map((e) => KeyBinding(title: e.value.title.tr, actKey: e.key))
                    .toList())),

            const SizedBox(height: 15),
            _TittleItem(title: 'Miscellaneous'.tr, icon: 'questionmark')
          ])));

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
        onTap: () {
          if (settingDialog.isShowing) return;
          settingDialog.show();
        },
        decorators: [
          const AnimatedButtonOpacityDecorator(minOpacity: 0.9),
          const AnimatedButtonScaleDecorator(max: 1.1),
          AnimatedButtonTooltipDecorator(
              childBuilder: (tag) => Text('Settings'.tr),
              position: const GameTooltipPosition.centerLeft())
        ],
        child: GifManager.inst
            .misc('settings')
            .builder
            .initWithShadow(filterQuality: FilterQuality.none, height: 42, width: 42));
  }
}

class _TittleItem extends StatelessWidget {
  const _TittleItem({required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 1.95),
        child: Row(children: [
          GifManager.inst.misc(icon).builder.initWithShadow(height: 27.297, width: 27.297),
          const SizedBox(width: 5.850),
          Text(
            title,
            style: const TextStyle(fontSize: 19.5, fontVariations: [FontVariation.weight(700)]),
          ),
        ]));
  }
}

class SystemSettings extends GetxController {
  SystemSettings._internal();
  static final SystemSettings _inst = SystemSettings._internal();
  static SystemSettings get inst => _inst;

  RxDouble volume = 0.4.obs;

  String get volumeToString => (volume * 100).toStringAsFixed(0);

  final Map<LogicalKeyboardKey, KeyMap> _defaultKeyMaps = {
    LogicalKeyboardKey.keyB: KeyMap(title: 'Brush', act: () {}, order: 0),
    LogicalKeyboardKey.keyF: KeyMap(title: 'Fill', act: () {}, order: 1),
    LogicalKeyboardKey.keyU: KeyMap(title: 'Undo', act: () {}, order: 2),
    LogicalKeyboardKey.keyC: KeyMap(title: 'Clear', act: () {}, order: 3),
    LogicalKeyboardKey.keyS: KeyMap(title: 'Swap', act: () {}, order: 4),
  };

  resetKeyMaps() {
    keyMaps.value = _defaultKeyMaps;
  }

  late RxMap<LogicalKeyboardKey, KeyMap> keyMaps = _defaultKeyMaps.obs;
  bool changeKey(LogicalKeyboardKey oldKey, LogicalKeyboardKey newKey) {
    if (oldKey == newKey) return true;
    if (keyMaps[newKey] != null) return false;

    keyMaps[newKey] = keyMaps.remove(oldKey)!;

    return true;
  }
}

class KeyMap {
  KeyMap({required this.title, required this.act, required this.order});
  final String title;
  void Function() act;
  int order;
}
