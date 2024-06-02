//import 'dart:io';

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

// enum AnimatedButtonTooltipPosition { left, top, right, bottom }

// class AnimatedButtonTooltipDecorator extends AnimatedButtonDecorator {
//   AnimatedButtonTooltipDecorator(
//       {required this.tooltip, required this.position});
//   String tooltip;
//   AnimatedButtonTooltipPosition position;
//   void show() {
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(Get.context!).insert(_overlayEntry!);
//   }

//   void hide() {
//     _overlayEntry?.remove();
//   }

//   @override
//   void decorate(AnimatedButton controller) {
//     // if (kIsWeb) {
//     // modify onEnter, onExit
//     var onEnter = controller.onEnter;
//     controller.onEnter = (e) {
//       show();
//       onEnter(e);
//     };

//     var onExit = controller.onExit;
//     controller.onExit = (e) {
//       hide();
//       onExit(e);
//     };
//     // } else if (Platform.isAndroid || Platform.isIOS) {
//     //   // modify onLongPress, onLongPressEnd for mobile platform
//     //   var onLongPress = controller.onLongPress;
//     //   controller.onLongPress = (onLongPress == null)
//     //       ? show
//     //       : () {
//     //           onLongPress();
//     //           show();
//     //         };

//     //   var onLongPressEnd = controller.onLongPressEnd;
//     //   controller.onLongPressEnd = (onLongPressEnd == null)
//     //       ? (e) => hide()
//     //       : (e) {
//     //           onLongPressEnd(e);
//     //           hide();
//     //         };
//     // }
//   }

//   OverlayEntry? _overlayEntry;
//   OverlayEntry _createOverlayEntry() {
//     return OverlayEntry(builder: (ct) {
//       return const Positioned(child: Text('tool tip'));
//     });
//   }
// }

// class AnimatedButtonScaleDecorator extends AnimatedButtonDecorator {
//   @override
//   void decorate(AnimatedButton controller) {
//     // wrap the widget with ScaleTransition
//     var widget = controller.child;
//     controller.child =
//         ScaleTransition(scale: controller.animation, child: widget);
//   }
// }
