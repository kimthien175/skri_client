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

  static const Color activeColor = Color(0xff56b2fd);

  @override
  State<InputContainer> createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: AnimatedButton.duration);

    var focusNode = widget.focusNode;
    if (focusNode != null) {
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
  }

  bool get _hasFocus => widget.focusNode?.hasFocus == true;

  bool isHovered = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
                    color: Colors.white,
                    borderRadius: GlobalStyles.borderRadius,
                    border: Border.all(color: color, width: 2.0)),
                child: widget.child ??
                    (widget.builder != null ? widget.builder!(controller) : null))));
  }
}
