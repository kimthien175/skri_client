import 'package:cd_mobile/utils/overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../builder.dart';
import '../decorator.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:io';

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
    if (overlayEntry == null) return;
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  static Color tooltipBackgroundColor = const Color.fromRGBO(69, 113, 255, 1.0);

  Widget leftAlign(Widget child, double ratio) {
    var newChild = Row(mainAxisSize: MainAxisSize.min, children: [child, _TooltipArrow.left()]);
    return Align(
        alignment: Alignment.centerRight,
        child: ratio == 1.0
            ? newChild
            : Transform.scale(
                scale: ratio,
                alignment: Alignment.centerRight,
                child: newChild,
              ));
  }

  Widget rightAlign(Widget child, double ratio) {
    var newChild = Row(mainAxisSize: MainAxisSize.min, children: [_TooltipArrow.right(), child]);
    return Align(
        alignment: Alignment.centerLeft,
        child: ratio == 1.0
            ? newChild
            : Transform.scale(
                scale: ratio,
                alignment: Alignment.centerLeft,
                child: newChild,
              ));
  }

  Widget topAlign(Widget child, double ratio) {
    var newChild = Column(mainAxisSize: MainAxisSize.min, children: [child, _TooltipArrow.top()]);
    return Align(
        alignment: Alignment.bottomCenter,
        child: ratio == 1.0
            ? newChild
            : Transform.scale(scale: ratio, alignment: Alignment.bottomCenter, child: newChild));
  }

  Widget bottomAlign(Widget child, double ratio) {
    var newChild =
        Column(mainAxisSize: MainAxisSize.min, children: [_TooltipArrow.bottom(), child]);
    return Align(
        alignment: Alignment.topCenter,
        child: ratio == 1.0
            ? newChild
            : Transform.scale(scale: ratio, alignment: Alignment.topCenter, child: newChild));
  }

  @override
  void decorate(AnimatedButtonBuilder builder) {
    // if (kIsWeb) {
    // modify onEnter, onExit
    builder.onEnter.add((e) {
      if (overlayEntry != null) return;
      //#region show tooltip

      // get button position
      var box = builder.buttonKey.currentContext!.findRenderObject() as RenderBox;

      var ratio = _scale();
      Size size = box.size * ratio;

      var offset = box.localToGlobal(Offset.zero);
      //#region create overlay

      Widget Function(Widget) tooltipBuilder;

      switch (position) {
        case AnimatedButtonTooltipPosition.left:
          // knowing the button stay on the top half or bottom half
          if (offset.dy + size.height / 2 <= Get.height / 2) {
            // top half
            tooltipBuilder = (Widget child) => Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                      width: offset.dx,
                      height: offset.dy * 2 + size.height,
                      child: leftAlign(child, ratio)),
                );
          } else {
            // bottom half
            tooltipBuilder = (Widget child) => Positioned(
                left: 0,
                bottom: 0,
                child: SizedBox(
                    width: offset.dx,
                    height: (Get.height - offset.dy) * 2 - size.height,
                    child: leftAlign(child, ratio)));
          }
          break;
        case AnimatedButtonTooltipPosition.top:
          // know left half or right half
          if (offset.dx + size.width / 2 <= Get.width / 2) {
            // left half
            tooltipBuilder = (Widget child) => Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                    width: offset.dx * 2 + size.width,
                    height: offset.dy,
                    child: topAlign(child, ratio)));
          } else {
            // right half
            tooltipBuilder = (Widget child) => Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                    width: (Get.width - offset.dx) * 2 - size.width,
                    height: offset.dy,
                    child: topAlign(child, ratio)));
          }

          break;
        case AnimatedButtonTooltipPosition.right:
          // know top half or bottom half
          if (offset.dy + size.height / 2 <= Get.height / 2) {
            // top half
            tooltipBuilder = (Widget child) => Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                    height: offset.dy * 2 + size.height,
                    width: Get.width - offset.dx - size.width,
                    child: rightAlign(child, ratio)));
          } else {
            // bottom half
            tooltipBuilder = (Widget child) => Positioned(
                bottom: 0,
                right: 0,
                child: SizedBox(
                    height: (Get.height - offset.dy) * 2 - size.height,
                    width: Get.width - offset.dx - size.width,
                    child: rightAlign(child, ratio)));
          }

          break;
        default:
          // know left half or right half
          if (offset.dx + size.width / 2 <= Get.width / 2) {
            // left half
            tooltipBuilder = (Widget child) {
              return Positioned(
                  left: 0,
                  bottom: 0,
                  child: SizedBox(
                      width: offset.dx * 2 + size.width,
                      height: Get.height - offset.dy - size.height,
                      child: bottomAlign(child, ratio)));
            };
          } else {
            // right half
            tooltipBuilder = (Widget child) => Positioned(
                right: 0,
                bottom: 0,
                child: SizedBox(
                    width: (Get.width - offset.dx) * 2 - size.width,
                    height: Get.height - offset.dy - size.height,
                    child: bottomAlign(child, ratio)));
          }
      }

      overlayEntry = OverlayEntry(
          builder: (BuildContext context) => tooltipBuilder(Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: tooltipBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(3))),
              child: DefaultTextStyle(
                style: const TextStyle(
                    color: Color.fromRGBO(240, 240, 240, 1),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.0,
                    fontFamily: 'Nunito'),
                child: Text(
                  tooltip,
                ),
              ))));

      //#endregion

      addOverlay(overlayEntry!);
      //#endregion
    });

    // removeOverlay on reverse end
    builder.onReverseEnd.add(removeOverlayEntry);
    builder.cleanUpCallbacks.add(removeOverlayEntry);

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

class _ArrowClip extends CustomClipper<Path> {
  _ArrowClip.left() {
    _path = (size) => Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height);
  }
  _ArrowClip.top() {
    _path = (size) => Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height);
  }
  _ArrowClip.right() {
    _path = (size) => Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height / 2);
  }
  _ArrowClip.bottom() {
    _path = (size) => Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, 0);
  }
  late final Path Function(Size) _path;
  @override
  Path getClip(Size size) => _path(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _TooltipArrow extends StatelessWidget {
  _TooltipArrow.left() {
    clipper = _ArrowClip.left();
    height = 20;
    width = 10;
  }
  _TooltipArrow.right() {
    clipper = _ArrowClip.right();
    height = 20;
    width = 10;
  }
  _TooltipArrow.top() {
    clipper = _ArrowClip.top();
    height = 10;
    width = 20;
  }
  _TooltipArrow.bottom() {
    clipper = _ArrowClip.bottom();
    height = 10;
    width = 20;
  }

  late final CustomClipper<Path> clipper;
  late final double height;
  late final double width;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
        clipper: clipper,
        child: Container(
            height: height,
            width: width,
            color: AnimatedButtonTooltipDecorator.tooltipBackgroundColor));
  }
}

enum AnimatedButtonTooltipPosition { left, top, right, bottom }
