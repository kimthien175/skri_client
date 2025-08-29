// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/services.dart';
import 'package:skribbl_client/models/gif_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/settings.dart';

import 'manager.dart';
import 'mode.dart';
import 'widgets/color.dart';
import 'widgets/stroke.dart';

class DrawWidget extends StatefulWidget {
  const DrawWidget({super.key});

  @override
  State<DrawWidget> createState() => _DrawWidgetState();
}

class _DrawWidgetState extends State<DrawWidget> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        var settings = SystemSettings.inst;
        var keyMap = settings.keyMaps[event.logicalKey];
        if (keyMap != null) {
          keyMap.act();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) => focusNode.requestFocus(),
        child: Focus(
            autofocus: true,
            focusNode: focusNode,
            child: const Column(children: [
              DrawWidgetCanvas(),
              SizedBox(height: 6),
              SizedBox(
                  width: 800,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    RecentColor(),
                    SizedBox(width: 6),
                    ColorSelector(),
                    SizedBox(width: 6),
                    StrokeValueSelector(),
                    Spacer(),
                    BrushButton(),
                    SizedBox(width: 6),
                    FillButton(),
                    Spacer(),
                    UndoButton(),
                    SizedBox(width: 6),
                    ClearButton()
                  ]))
            ])));
  }
}

mixin KeyMapWrapper on StatelessWidget {
  KeyMap get keyMap;
  Widget get child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: keyMap.act,
        child: Obx(() {
          var keyMaps = SystemSettings.inst.keyMaps;
          return Stack(children: [
            child,
            Positioned(
                right: 2,
                top: -2,
                child: Text(keyMaps.keys.firstWhere((key) => keyMaps[key] == keyMap).keyLabel,
                    style: TextStyle(fontSize: 13, fontVariations: [FontVariation.weight(900)])))
          ]);
        }));
  }
}

class BrushButton extends StatelessWidget with KeyMapWrapper {
  const BrushButton({super.key});

  static const KEYMAP = KeyMap(title: 'Brush', act: _act, order: 0);

  @override
  KeyMap get keyMap => KEYMAP;

  static void _act() {
    if (DrawManager.inst.currentMode is BrushMode) return;
    DrawManager.inst.currentMode = DrawMode.brush();
  }

  @override
  Widget get child => Obx(() => Container(
      decoration: BoxDecoration(
          color: DrawManager.inst.currentMode is BrushMode
              ? const Color.fromRGBO(171, 102, 235, 1)
              : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: GifManager.inst.misc('pen').builder.initWithShadow().fit(height: 48, width: 48)));
}

class FillButton extends StatelessWidget with KeyMapWrapper {
  const FillButton({super.key});

  static const KEYMAP = KeyMap(title: 'Fill', act: _act, order: 1);

  @override
  KeyMap get keyMap => KEYMAP;

  static void _act() {
    if (DrawManager.inst.currentMode is! FillMode) {
      DrawManager.inst.currentMode = DrawMode.fill();
    }
  }

  @override
  Widget get child => Obx(() => Container(
      decoration: BoxDecoration(
          color: DrawManager.inst.currentMode is FillMode
              ? const Color.fromRGBO(171, 102, 235, 1)
              : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: GifManager.inst.misc('fill').builder.initWithShadow().fit(height: 48, width: 48)));
}

class UndoButton extends StatelessWidget with KeyMapWrapper {
  const UndoButton({super.key});

  static final KeyMap KEYMAP =
      KeyMap(title: 'Undo', act: () => DrawManager.inst.popTail(), order: 2);

  @override
  KeyMap get keyMap => KEYMAP;

  @override
  Widget get child => const _UndoButtonChild();
}

class _UndoButtonChild extends StatefulWidget {
  const _UndoButtonChild();

  @override
  State<_UndoButtonChild> createState() => __UndoButtonChildState();
}

class __UndoButtonChildState extends State<_UndoButtonChild> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: Container(
            decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(3))),
            child: Opacity(
                opacity: isHovered ? 1 : 0.7,
                child: GifManager.inst
                    .misc('undo')
                    .builder
                    .initWithShadow()
                    .fit(width: 48, height: 48))));
  }
}

class ClearButton extends StatelessWidget with KeyMapWrapper {
  const ClearButton({super.key});

  @override
  Widget get child => const _ClearButtonChild();

  static final KeyMap KEYMAP =
      KeyMap(title: 'Clear', act: () => DrawManager.inst.clear(), order: 3);

  @override
  KeyMap get keyMap => KEYMAP;
}

class _ClearButtonChild extends StatefulWidget {
  const _ClearButtonChild();

  @override
  State<_ClearButtonChild> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<_ClearButtonChild> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: InkWell(
            onTap: DrawManager.inst.clear,
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(3))),
                child: Opacity(
                    opacity: isHovered ? 1 : 0.7,
                    child: GifManager.inst
                        .misc('clear')
                        .builder
                        .initWithShadow()
                        .fit(height: 48, width: 48)))));
  }
}
