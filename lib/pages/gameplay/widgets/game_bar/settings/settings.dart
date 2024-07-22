import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/slider.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../../../../../models/models.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  void showSettings() {
    GameDialog(
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
                  decorators: [
                    const AnimatedButtonBackgroundColorDecorator(),
                    AnimatedButtonTooltipDecorator(tooltip: 'reset_hotkeys_tooltip'.tr)
                  ],
                  child: Text('Reset'.tr),
                )
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _KeyBinding(act: 'Brush'.tr, actKey: SystemSettings.inst.brushKey),
                _KeyBinding(act: 'Fill'.tr, actKey: SystemSettings.inst.fillKey),
                _KeyBinding(act: 'Undo'.tr, actKey: SystemSettings.inst.undoKey),
                _KeyBinding(act: 'Clear'.tr, actKey: SystemSettings.inst.clearKey),
                _KeyBinding(act: 'Swap'.tr, actKey: SystemSettings.inst.swapKey),
              ]),
              //
              const SizedBox(height: 15),
              _TittleItem(title: 'Miscellaneous'.tr, icon: 'questionmark')
            ]))).show();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
        onTap: showSettings,
        decorators: [
          const AnimatedButtonOpacityDecorator(minOpacity: 0.9),
          const AnimatedButtonScaleDecorator(max: 1.1),
          AnimatedButtonTooltipDecorator(tooltip: 'Settings', position: const TooltipPositionLeft())
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

class _KeyBinding extends StatelessWidget {
  const _KeyBinding({required this.act, required this.actKey});
  final String act;
  final LogicalKeyboardKey actKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(act,
            style: const TextStyle(fontSize: 15, fontVariations: [FontVariation.weight(440)])),
        Text(actKey.keyLabel)
      ],
    );
  }
}

class SystemSettings extends GetxController {
  SystemSettings._internal();
  static final SystemSettings _inst = SystemSettings._internal();
  static SystemSettings get inst => _inst;

  RxDouble volume = 0.01.obs;

  String get volumeToString => (volume * 100).toStringAsFixed(0);

  LogicalKeyboardKey brushKey = LogicalKeyboardKey.keyB;
  LogicalKeyboardKey fillKey = LogicalKeyboardKey.keyF;
  LogicalKeyboardKey undoKey = LogicalKeyboardKey.keyU;
  LogicalKeyboardKey clearKey = LogicalKeyboardKey.keyC;
  LogicalKeyboardKey swapKey = LogicalKeyboardKey.keyS;
}
