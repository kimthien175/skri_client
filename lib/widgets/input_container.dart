import 'package:flutter/material.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

class InputContainer extends StatefulWidget {
  const InputContainer(
      {this.child,
      this.height,
      this.width,
      this.alignment,
      this.constraints,
      this.margin,
      this.focusNode,
      super.key});

  final Widget? child;

  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final Alignment? alignment;
  final EdgeInsets? margin;
  final FocusNode? focusNode;

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
        print('changed');
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
    widget.focusNode?.dispose();
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
        child: _BorderTransition(
            listenable: controller
                .drive(ColorTween(begin: const Color(0xff707070), end: const Color(0xff56b2fd))),
            //
            height: widget.height,
            width: widget.width,
            constraints: widget.constraints,
            alignment: widget.alignment,
            margin: widget.margin,
            child: widget.child));
  }
}

class _BorderTransition extends AnimatedWidget {
  const _BorderTransition(
      {this.child,
      this.height,
      this.width,
      this.alignment,
      this.constraints,
      this.margin,
      required super.listenable});
  final Widget? child;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final Alignment? alignment;
  final EdgeInsets? margin;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        constraints: constraints,
        alignment: alignment,
        margin: margin,
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GlobalStyles.borderRadius,
            border: Border.all(color: (listenable as Animation).value)),
        child: child);
  }
}
