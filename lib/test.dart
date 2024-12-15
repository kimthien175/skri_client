import 'package:flutter/material.dart';

import 'package:skribbl_client/widgets/dialog/dialog.dart';
import 'package:skribbl_client/widgets/hover_button.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  // static final settingDialog = GameDialog(
  //     title: Builder(builder: (_) => Text('Settings'.tr)),
  //     content: SizedBox(
  //         width: 500,
  //         child: Column(children: [
  //           Obx(() => _TittleItem(
  //               icon: 'audio', title: "${'Volume'.tr} ${SystemSettings.inst.volumeToString}%")),
  //           const SettingsSlider(),
  //           //
  //           const SizedBox(height: 15),
  //           //
  //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //             _TittleItem(title: "Hotkeys".tr, icon: 'key'),
  //             GameTooltipWidget(
  //                 child: HoverButton(
  //                   onTap: SystemSettings.inst.resetKeyMaps,
  //                   child: Text('Reset'.tr),
  //                 ),
  //                 tooltipContentBuilder: () => Text('reset_hotkeys_tooltip'.tr)),
  //             // AnimatedButton(
  //             //   onTap: SystemSettings.inst.resetKeyMaps,
  //             //   decorators: [
  //             //    // const AnimatedButtonBackgroundColorDecorator(),
  //             //     AnimatedButtonTooltipDecorator(
  //             //         childBuilder: () => Text('reset_hotkeys_tooltip'.tr))
  //             //   ],
  //             //   child: Text('Reset'.tr),
  //             // )
  //           ]),
  //           Obx(() => Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: (SystemSettings.inst.keyMaps.entries.toList()
  //                     ..sort((a, b) => a.value.order.compareTo(b.value.order)))
  //                   .map((e) => KeyBinding(title: e.value.title.tr, actKey: e.key))
  //                   .toList())),

  //           const SizedBox(height: 15),
  //           _TittleItem(title: 'Miscellaneous'.tr, icon: 'questionmark')
  //         ])));

  static GameDialog settingDialog = GameDialog.cache(
      tag: 'gameplay-confirm-leave',
      builder: () => GameDialog(
          onQuit: (hide) async {
            await hide();
            return false;
          },
          title: const Text("You're leaving the game"),
          content: const Text('Are you sure?'),
          exitTap: true,
          buttons: const RowRenderObjectWidget(
              children: [GameDialogButton.yes(flex: 2), GameDialogButton.no()])));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: HoverButton(
      onTap: settingDialog.show,
      child: const Text('setting'),
    )));
  }
}
