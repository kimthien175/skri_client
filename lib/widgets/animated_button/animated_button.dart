library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skribbl_client/widgets/animated_button/decorator.dart';
import 'package:skribbl_client/widgets/dialog/dialog.dart';

export 'decorator.dart';

class AnimatedButton extends StatefulWidget {
  /// if you only use `AnimatedButtonBackgroundColorDecorator`, use `HoverButton` instead for lightweight
  ///
  /// for short live solution, `decorators` must be const
  /// `dialogToShow` is expected persistent
  const AnimatedButton({
    super.key,
    required this.child,
    required this.decorators,
    this.onTap,
    this.dialogToShow,
    this.skipTravelFocus = false,
  }) : assert(onTap == null || dialogToShow == null, "AnimatedButton can't handle both");
  final Widget child;
  final List<AnimatedButtonDecorator> decorators;
  final void Function()? onTap;
  final GameDialog? dialogToShow;
  final bool skipTravelFocus;

  static const Duration duration = Duration(milliseconds: 130);

  @override
  State<AnimatedButton> createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late final FocusNode focusNode;
  bool isHovered = false;

  late final void Function()? onTap;

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    focusNode.skipTraversal = widget.skipTravelFocus;
  }

  @override
  void initState() {
    super.initState();

    onTap = widget.onTap ?? widget.dialogToShow?.show;

    child = widget.child;

    for (var decorator in widget.decorators) {
      decorator.decorate(this);
    }

    focusNode = FocusNode(
      skipTraversal: widget.skipTravelFocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (onTap != null) {
              onTap!.call();
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

    if (widget.dialogToShow != null) {
      widget.dialogToShow!.anchorFocusCallback = anchorFocusCallback;
    }
  }

  void anchorFocusCallback() {
    if (mounted && focusNode.canRequestFocus) {
      focusNode.requestFocus();
    }
  }

  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: AnimatedButton.duration,
  );
  late final CurvedAnimation curvedAnimation = CurvedAnimation(
    curve: Curves.linear,
    parent: controller,
  );

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
    // check dialog still keep this callback instance then set it to null,
    // otherwise new instance of AnimatedButtonState already called initState and set new callback instance
    if (widget.dialogToShow != null &&
        widget.dialogToShow!.anchorFocusCallback == anchorFocusCallback) {
      widget.dialogToShow!.anchorFocusCallback = null;
    }

    super.dispose();
  }

  void active() {
    for (var callback in onEnterCallbacks) {
      callback();
    }
    controller.forward();
  }

  void unactive() {
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
        onTap: onTap,
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
          child: child,
        ),
      ),
    );
  }
}
