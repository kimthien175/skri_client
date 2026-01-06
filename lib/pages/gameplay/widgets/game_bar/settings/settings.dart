import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/sound.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/draw_widget.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw/widgets/color.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/slider.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../../../../../models/models.dart';
import 'key_binding.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  static final settingDialog = OverlayController.put(
    tag: 'settings_menu',
    permanent: true,
    builder: () => GameDialog(
      title: Builder(builder: (_) => Text('Settings'.tr)),
      content: SizedBox(
        width: 500,
        child: Column(
          children: [
            _TittleItem(
              icon: 'audio',
              title: Obx(() => Text("${'Volume'.tr} ${SystemSettings.inst.volumeToString}%")),
            ),
            const SettingsSlider(),
            //
            const SizedBox(height: 15),
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TittleItem(title: Text("Hotkeys".tr), icon: 'key'),
                GameTooltipWrapper(
                  tooltip: Builder(builder: (_) => Text('reset_hotkeys_tooltip'.tr)),
                  child: HoverButton(
                    onTap: SystemSettings.inst.resetKeyMaps,
                    child: Text('Reset'.tr),
                  ),
                ),
              ],
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    (SystemSettings.inst.keyMaps.entries.toList()
                          ..sort((a, b) => a.value.order.compareTo(b.value.order)))
                        .map((e) => KeyBinding(title: e.value.title.tr, actKey: e.key))
                        .toList(),
              ),
            ),

            const SizedBox(height: 15),
            _TittleItem(title: Text('Miscellaneous'.tr), icon: 'questionmark'),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      dialogToShow: settingDialog,
      decorators: const [
        AnimatedButtonOpacityDecorator(minOpacity: 0.9),
        AnimatedButtonScaleDecorator(max: 1.1),
        AnimatedButtonTooltipDecorator(
          tooltip: _SettingsButtonTooltipContent(),
          position: GameTooltipPosition.centerLeft(),
        ),
      ],
      child: GifManager.inst
          .misc('settings')
          .builder
          .initWithShadow(filterQuality: FilterQuality.none)
          .fit(height: 42),
    );
  }
}

class _SettingsButtonTooltipContent extends StatelessWidget {
  const _SettingsButtonTooltipContent();
  @override
  Widget build(BuildContext context) {
    return Text('Settings'.tr);
  }
}

class _TittleItem extends StatelessWidget {
  const _TittleItem({required this.title, required this.icon});

  final Widget title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.95),
      child: Row(
        children: [
          GifManager.inst.misc(icon).builder.initWithShadow().fit(height: 27.297, width: 27.297),
          const SizedBox(width: 5.850),
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 19.5, fontVariations: [FontVariation.weight(700)]),
            child: title,
          ),
        ],
      ),
    );
  }
}

class SystemSettings extends GetxController {
  SystemSettings._internal();
  static final SystemSettings _inst = SystemSettings._internal();
  static SystemSettings get inst => _inst;

  final RxDouble _volume = 0.5.obs;
  double get volume => _volume.value;
  set volume(double value) {
    _volume.value = value;
    Sound.inst.setVolume(value);
  }

  String get volumeToString => (volume * 100).toStringAsFixed(0);

  final Map<LogicalKeyboardKey, KeyMap> _defaultKeyMaps = {
    LogicalKeyboardKey.keyB: BrushButton.KEYMAP,
    LogicalKeyboardKey.keyF: FillButton.KEYMAP,
    LogicalKeyboardKey.keyU: UndoButton.KEYMAP,
    LogicalKeyboardKey.keyC: ClearButton.KEYMAP,
    LogicalKeyboardKey.keyS: RecentColor.KEYMAP,
  };

  void resetKeyMaps() {
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
  const KeyMap({required this.title, required this.act, required this.order});
  final String title;
  final void Function() act;
  final int order;
}
