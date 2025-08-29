import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/game_bar/settings/settings.dart';

import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

const _borderRadius = BorderRadius.all(Radius.circular(5));

class SettingsSlider extends StatefulWidget {
  const SettingsSlider({super.key});

  @override
  State<SettingsSlider> createState() => _SettingsSliderState();
}

class _SettingsSliderState extends State<SettingsSlider> with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(vsync: this, duration: AnimatedButton.duration);

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // decrease volume
            SystemSettings.inst.volume = clampDouble(volume - 0.01, 0.0, 1.0);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // increase volume
            SystemSettings.inst.volume = clampDouble(volume + 0.01, 0.0, 1.0);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
    focusNode.addListener(() {
      if (inArea) return;
      if (onInteracting) return;
      if (focusNode.hasFocus) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  double get volume => SystemSettings.inst.volume;

  double newVolume(double dx, double maxWidth) {
    if (dx <= _thumbSize / 2) return 0.0;
    if (dx >= maxWidth - _thumbSize / 2) return 1.0;

    return (dx - _thumbSize / 2) / (maxWidth - _thumbSize);
  }

  static const _sliderHeight = 7.5;

  static const Color _borderColor = Color(0x69ffffff);

  static const double _thumbSize = 16;

  bool inArea = false;
  bool onInteracting = false;

  @override
  Widget build(BuildContext context) {
    var activeTweenColor =
        controller.drive(ColorTween(begin: const Color(0xff0075ff), end: const Color(0xff005cc8)));
    return Focus(
        focusNode: focusNode,
        child: LayoutBuilder(builder: (ct, constraints) {
          var maxWidth = constraints.maxWidth;
          return GestureDetector(
              onPanStart: (details) {
                onInteracting = true;
                focusNode.requestFocus();
              },
              onPanUpdate: (details) {
                SystemSettings.inst.volume = newVolume(details.localPosition.dx, maxWidth);
              },
              onPanEnd: (details) {
                onInteracting = false;
                if (inArea) return;
                if (focusNode.hasFocus) return;
                controller.reverse();
              },
              onTapDown: (details) {
                focusNode.requestFocus();
                SystemSettings.inst.volume = newVolume(details.localPosition.dx, maxWidth);
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: _thumbSize,
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        inArea = true;
                        if (onInteracting) return;
                        if (focusNode.hasFocus) return;
                        controller.forward();
                      },
                      onExit: (event) {
                        inArea = false;
                        if (onInteracting) return;
                        if (focusNode.hasFocus) return;
                        controller.reverse();
                      },
                      child: Obx(() => Stack(
                              alignment: Alignment.centerLeft,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                    foregroundDecoration: BoxDecoration(
                                        borderRadius: _borderRadius,
                                        border: Border.all(color: _borderColor, width: 0.35)),
                                    constraints: const BoxConstraints.expand(height: _sliderHeight),
                                    child: Row(children: [
                                      _BackgroundColorTransition(
                                        width: _thumbSize / 2 + (maxWidth - _thumbSize) * volume,
                                        listenable: activeTweenColor,
                                      ),
                                      Expanded(
                                          child: _BackgroundColorTransition(
                                              listenable: controller.drive(ColorTween(
                                                  begin: const Color(0xffefefef),
                                                  end: const Color(0xffe0e0e0)))))
                                    ])),
                                Positioned(
                                    left: volume * (maxWidth - _thumbSize),
                                    child: _BackgroundColorTransition(
                                        listenable: activeTweenColor,
                                        width: _thumbSize,
                                        shape: BoxShape.circle))
                              ])))));
        }));
  }
}

class _BackgroundColorTransition extends AnimatedWidget {
  const _BackgroundColorTransition(
      {required super.listenable, this.width, this.shape = BoxShape.rectangle});
  final double? width;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return shape == BoxShape.rectangle
        ? Container(
            width: width,
            decoration:
                BoxDecoration(color: (listenable as Animation).value, borderRadius: _borderRadius),
          )
        : Container(
            width: width,
            height: width,
            decoration: BoxDecoration(color: (listenable as Animation).value, shape: shape),
          );
  }
}
