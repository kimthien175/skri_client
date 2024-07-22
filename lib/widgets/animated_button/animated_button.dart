library animated_button;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late FocusNode focusNode;
  bool isHovered = false;
  @override
  void initState() {
    super.initState();
    child = widget.child;

    for (var decorator in widget.decorators) {
      decorator.decorate(this);
    }

    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (widget.onTap != null) {
              widget.onTap!();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
    );

    focusNode.addListener(() {
      if (isHovered) return;
      if (focusNode.hasFocus) {
        active();
      } else {
        unactive();
      }
    });
  }

  late final AnimationController controller =
      AnimationController(vsync: this, duration: AnimatedButton.duration);
  late final CurvedAnimation curvedAnimation =
      CurvedAnimation(curve: Curves.linear, parent: controller);

  final GlobalKey _buttonKey = GlobalKey();
  GlobalKey get buttonKey => _buttonKey;

  late Widget child;

  final List<void Function()> onEnterCallbacks = [];
  final List<void Function()> onExitCallbacks = [];
  final List<void Function()> onReverseEnd = [];

  @override
  void dispose() {
    for (var decorator in widget.decorators) {
      decorator.clean();
    }
    curvedAnimation.dispose();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  active() {
    for (var callback in onEnterCallbacks) {
      callback();
    }
    controller.forward();
  }

  unactive() {
    for (var callback in onExitCallbacks) {
      callback();
    }
    controller.reverse().then((_) {
      for (var callback in onReverseEnd) {
        callback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: focusNode,
        child: GestureDetector(
            key: _buttonKey,
            onTap: widget.onTap,
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (e) {
                  isHovered = true;
                  if (focusNode.hasFocus) return;
                  active();
                },
                onExit: (e) {
                  isHovered = false;
                  if (focusNode.hasFocus) return;
                  unactive();
                },
                child: child)));
  }
}
