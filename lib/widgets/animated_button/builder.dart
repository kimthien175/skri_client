import 'package:skribbl_client/widgets/animated_button/decorator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AnimatedButtonBuilder {
  AnimatedButtonBuilder({
    required this.child,
    this.onTap,
    required this.decorators,
  }) {
    // decorating
    for (var decorator in decorators) {
      decorator.decorate(this);
    }
  }

  Widget child;
  void Function()? onTap;
  late final List<AnimatedButtonDecorator> decorators;

  final List<void Function(PointerEnterEvent)> onEnterCallbacks = [];
  final List<void Function(PointerExitEvent)> onExitCallbacks = [];

  final GlobalKey buttonKey = GlobalKey();

  Widget build() {
    return GestureDetector(
        key: buttonKey,
        onTap: onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (e) {
              for (var callback in onEnterCallbacks) {
                callback(e);
              }
            },
            onExit: (e) {
              for (var callback in onExitCallbacks) {
                callback(e);
              }
            },
            child: child));
  }

  static const Duration duration = Duration(milliseconds: 130);

  void dispose() {
    for (var decorator in decorators) {
      decorator.clean();
    }
  }
}
