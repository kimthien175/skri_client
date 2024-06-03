//import 'dart:io';

import 'package:cd_mobile/utils/overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'builder.dart';

class AnimatedButtonDecorator {
  void decorate(AnimatedButtonBuilder builder) {}
}

class AnimatedButtonOpacityDecorator extends AnimatedButtonDecorator {
  AnimatedButtonOpacityDecorator({this.minOpacity = 0.5});

  final RxBool _visible = false.obs;
  final double minOpacity;

  void cleanUp() {
    _visible.close();
  }

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // modify onEnter and onExit behavior
    var onEnter = builder.onEnter;
    builder.onEnter = (e) {
      print('decorator onEnter');
      _visible.value = true;
      onEnter(e);
    };

    var onExit = builder.onExit;
    builder.onExit = (e) {
      print('decorator onExit');
      _visible.value = false;
      onExit(e);
    };

    // modify widget: wrap widget with AnimatedOpacity

    var widget = builder.child;
    builder.child = Obx(() => AnimatedOpacity(
        opacity: _visible.value ? 1 : minOpacity,
        duration: AnimatedButtonController.duration,
        child: widget));
  }
}

enum AnimatedButtonTooltipPosition { left, top, right, bottom }

class AnimatedButtonTooltipDecorator extends AnimatedButtonDecorator {
  AnimatedButtonTooltipDecorator(
      {required this.tooltip,
      this.position = AnimatedButtonTooltipPosition.top,
      double Function()? scale}) {
    _scale = scale ?? () => 1.0;
  }
  final String tooltip;
  final AnimatedButtonTooltipPosition position;
  late final double Function() _scale;

  OverlayEntry? overlayEntry;

  void removeOverlayEntry() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // if (kIsWeb) {
    // modify onEnter, onExit
    var onEnter = builder.onEnter;
    builder.onEnter = (e) {
      //#region show tooltip

      removeOverlayEntry();

      // get button position
      var box =
          builder.buttonKey.currentContext!.findRenderObject() as RenderBox;

      var ratio = _scale();
      Size size = box.size * ratio;

      var offset = box.localToGlobal(Offset.zero);
      //#region create overlay

      Widget Function(Widget) tooltipBuilder;

      switch (position) {
        case AnimatedButtonTooltipPosition.left:
          // knowing the button stay on the top half or bottom half
          if (offset.dy + size.height / 2 <= (Get.height - 1) / 2) {
            // top half
            tooltipBuilder = (Widget child) => Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                      width: offset.dx + 1,
                      height: (offset.dy + 1) * 2 + size.height,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: ratio == 1.0
                              ? child
                              : Transform.scale(
                                  scale: ratio,
                                  alignment: Alignment.centerRight,
                                  child: child,
                                ))),
                );
          } else {
            // bottom half
            tooltipBuilder = (Widget child) => Positioned(
                left: 0,
                bottom: 0,
                child: SizedBox(
                    width: offset.dx + 1,
                    height: (Get.height - 1 - offset.dy) * 2 - size.height,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: ratio == 1.0
                            ? child
                            : Transform.scale(
                                scale: ratio,
                                alignment: Alignment.centerRight,
                                child: child,
                              ))));
          }
          break;
        case AnimatedButtonTooltipPosition.top:
          // know left half or right half
          if (offset.dx + size.width / 2 <= (Get.width - 1) / 2) {
            // left half
            tooltipBuilder = (Widget child) => Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                    width: (offset.dx + 1) * 2 + size.width,
                    height: offset.dy + 1,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ratio == 1.0
                            ? child
                            : Transform.scale(
                                scale: ratio,
                                alignment: Alignment.bottomCenter,
                                child: child))));
          } else {
            // right half
            tooltipBuilder = (Widget child) => Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                    width: (Get.width - 1 - offset.dx) * 2 - size.width,
                    height: offset.dy + 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ratio == 1.0
                          ? child
                          : Transform.scale(
                              scale: ratio,
                              alignment: Alignment.bottomCenter,
                              child: child,
                            ),
                    )));
          }

          break;
        case AnimatedButtonTooltipPosition.right:
          tooltipBuilder = (Widget child) => Positioned(
                top: offset.dy,
                left: offset.dx + size.width,
                child: child,
              );
          break;
        default:
          tooltipBuilder = (Widget child) => Positioned(
                left: offset.dx,
                top: offset.dy + size.height,
                child: child,
              );
      }

      overlayEntry = OverlayEntry(
          builder: (BuildContext context) => tooltipBuilder(
                Container(
                    color: Colors.white,
                    child: DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                        child: Text(tooltip))),
              ));

      //#endregion

      addOverlay(overlayEntry!);
      //#endregion

      onEnter(e);
    };

    var onExit = builder.onExit;
    builder.onExit = (e) {
      removeOverlayEntry();
      onExit(e);
    };
    // } else if (Platform.isAndroid || Platform.isIOS) {
    //   // modify onLongPress, onLongPressEnd for mobile platform
    //   var onLongPress = controller.onLongPress;
    //   controller.onLongPress = (onLongPress == null)
    //       ? show
    //       : () {
    //           onLongPress();
    //           show();
    //         };

    //   var onLongPressEnd = controller.onLongPressEnd;
    //   controller.onLongPressEnd = (onLongPressEnd == null)
    //       ? (e) => hide()
    //       : (e) {
    //           onLongPressEnd(e);
    //           hide();
    //         };
    // }
  }
}

class AnimatedButtonScaleDecorator extends AnimatedButtonDecorator {
  AnimatedButtonScaleDecorator({this.minSize = 0.9, this.maxSize = 1});
  final double minSize;
  final double maxSize;
  @override
  void decorate(AnimatedButtonBuilder builder) {
    // wrap the widget with ScaleTransition
    var widget = builder.child;
    builder.child =
        ScaleTransition(scale: builder.controller.animation, child: widget);
  }
}
