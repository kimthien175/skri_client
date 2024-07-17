import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../../../../models/models.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  void showSettings() {
    GameDialog(
        title: () => 'Settings'.tr,
        content: SizedBox(
            width: 500,
            child: Column(
              children: [
                _ItemTittle(title: "Volume 100%".tr, icon: 'audio'),

// volume slider
                Row(children: [
                  _ItemTittle(title: "Hotkeys".tr, icon: 'key'),
                  AnimatedButton(
                    decorators: [
                      AnimatedButtonBackgroundColorDecorator(
                          colorTween: ColorTween(
                        begin: GlobalStyles.colorPanelButton,
                        end: GlobalStyles.colorPanelButtonHover,
                      ))
                    ],
                    child: Text(
                      'Reset'.tr,
                      style: const TextStyle(
                          color: PanelStyles.textColor,
                          fontVariations: [FontVariation.weight(800)]),
                    ),
                  )
                ])
              ],
            ))).show();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
        onTap: showSettings,
        decorators: [
          AnimatedButtonOpacityDecorator(minOpacity: 0.9),
          AnimatedButtonScaleDecorator(max: 1.1),
          AnimatedButtonTooltipDecorator(tooltip: 'Settings', position: TooltipPositionLeft())
        ],
        child: GifManager.inst
            .misc('settings')
            .builder
            .initWithShadow(filterQuality: FilterQuality.none, height: 42, width: 42));
  }
}

class _ItemTittle extends StatelessWidget {
  const _ItemTittle({required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GifManager.inst.misc(icon).builder.initWithShadow(),
      Text(title,
          style: const TextStyle(fontSize: 19.5, fontVariations: [FontVariation.weight(700)]))
    ]);
  }
}
