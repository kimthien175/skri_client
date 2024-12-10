import 'package:flutter/material.dart';
import 'package:skribbl_client/utils/styles.dart';

import 'widgets.dart';

class InputContainer extends StatefulWidget {
  const InputContainer(
      {this.child,
      this.builder,
      this.height,
      this.width,
      this.alignment,
      this.constraints,
      this.margin,
      this.focusNode,
      this.color,
      this.padding = const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
      super.key})
      : assert(child == null || builder == null,
            'child and builder can\'t be assigned at the same time!');

  final Widget? child;
  final Widget Function(AnimationController controller)? builder;

  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final Alignment? alignment;
  final EdgeInsets? margin;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  static const Color activeColor = Color(0xff56b2fd);
  static double borderWidth = 1.5;

  @override
  State<InputContainer> createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: AnimatedButton.duration);

    focusNode = widget.focusNode ?? FocusNode();

    focusNode.addListener(() {
      if (isHovered) return;
      if (focusNode.hasFocus) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
    if (focusNode.hasFocus) controller.value = controller.upperBound;
  }

  bool get _hasFocus => widget.focusNode?.hasFocus == true;

  bool isHovered = false;

  @override
  void dispose() {
    controller.dispose();
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = MouseRegion(
        onEnter: (event) {
          isHovered = true;
          if (_hasFocus) return;
          controller.forward();
        },
        onExit: (event) {
          isHovered = false;
          if (_hasFocus) return;
          controller.reverse();
        },
        child: ColorTransition(
            listenable: controller
                .drive(ColorTween(begin: const Color(0xff707070), end: InputContainer.activeColor)),
            builder: (color) => Container(
                height: widget.height,
                width: widget.width,
                constraints: widget.constraints,
                alignment: widget.alignment,
                margin: widget.margin,
                padding: widget.padding,
                decoration: BoxDecoration(
                    color: widget.color ?? Colors.white,
                    borderRadius: GlobalStyles.borderRadius,
                    border: Border.all(color: color, width: InputContainer.borderWidth)),
                child: widget.child ??
                    (widget.builder != null ? widget.builder!(controller) : null))));

    if (widget.focusNode == null) child = Focus(focusNode: focusNode, child: child);

    return child;
  }
}
