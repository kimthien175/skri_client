library animated_button;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/decorator.dart';

export 'decorator.dart';

class AnimatedButton extends StatefulWidget {
  /// if you only use `AnimatedButtonBackgroundColorDecorator`, use `HoverButton` instead for lightweight
  const AnimatedButton({super.key, required this.child, required this.decorators, this.onTap});
  final Widget child;
  final List<AnimatedButtonDecorator> decorators;
  final void Function()? onTap;

  static const Duration duration = Duration(milliseconds: 130);

  @override
  State<AnimatedButton> createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    child = widget.child;

    for (var decorator in widget.decorators) {
      decorator.decorate(this);
    }
  }

  late final AnimationController controller =
      AnimationController(vsync: this, duration: AnimatedButton.duration);
  late final CurvedAnimation curvedAnimation =
      CurvedAnimation(curve: Curves.linear, parent: controller);

  final GlobalKey _buttonKey = GlobalKey();
  GlobalKey get buttonKey => _buttonKey;

  late Widget child;

  final List<void Function(PointerEnterEvent)> onEnterCallbacks = [];
  final List<void Function(PointerExitEvent)> onExitCallbacks = [];
  final List<void Function()> onReverseEnd = [];

  @override
  void dispose() {
    for (var decorator in widget.decorators) {
      decorator.clean();
    }
    curvedAnimation.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: _buttonKey,
        onTap: widget.onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (e) {
              for (var callback in onEnterCallbacks) {
                callback(e);
              }
              controller.forward();
            },
            onExit: (e) {
              for (var callback in onExitCallbacks) {
                callback(e);
              }
              controller.reverse().then((_) {
                for (var callback in onReverseEnd) {
                  callback();
                }
              });
            },
            child: child));
  }
}
