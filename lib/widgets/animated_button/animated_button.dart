library animated_button;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/decorator.dart';

export 'decorators/opacity.dart';
export 'decorators/scale.dart';
export 'decorators/tooltip/tooltip.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key, required this.child, required this.decorators, this.onTap});
  final Widget child;
  final List<AnimatedButtonDecorator> decorators;
  final void Function()? onTap;

  static const Duration duration = Duration(milliseconds: 130);

  @override
  State<AnimatedButton> createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> {
  @override
  void initState() {
    super.initState();
    child = widget.child;

    for (var decorator in widget.decorators) {
      decorator.decorate(this);
    }
  }

  final GlobalKey _buttonKey = GlobalKey();
  GlobalKey get buttonKey => _buttonKey;

  late Widget child;

  final List<void Function(PointerEnterEvent)> onEnterCallbacks = [];
  final List<void Function(PointerExitEvent)> onExitCallbacks = [];

  @override
  void dispose() {
    for (var decorator in widget.decorators) {
      decorator.clean();
    }
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
            },
            onExit: (e) {
              for (var callback in onExitCallbacks) {
                callback(e);
              }
            },
            child: child));
  }
}
