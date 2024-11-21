import 'package:flutter/services.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/color_transition.dart';

class HoverButton extends StatefulWidget {
  const HoverButton(
      {super.key,
      this.child,
      this.color = GlobalStyles.colorPanelButton,
      this.hoverColor = GlobalStyles.colorPanelButtonHover,
      this.onTap,
      this.borderRadius = GlobalStyles.borderRadius,
      this.height,
      this.width});

  final Widget? child;
  final Color color;
  final Color hoverColor;
  final void Function()? onTap;
  final BorderRadius? borderRadius;

  final double? width;
  final double? height;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this, duration: AnimatedButton.duration);
  late final FocusNode focusNode;

  bool isHovered = false;

  @override
  void initState() {
    super.initState();

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
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: focusNode,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              isHovered = true;
              if (focusNode.hasFocus) return;
              controller.forward();
            },
            onExit: (_) {
              isHovered = false;
              if (focusNode.hasFocus) return;
              controller.reverse();
            },
            child: GestureDetector(
                onTap: widget.onTap,
                child: ColorTransition(
                    listenable:
                        ColorTween(begin: widget.color, end: widget.hoverColor).animate(controller),
                    builder: (color) => Container(
                        height: widget.height,
                        width: widget.width,
                        padding: widget.height == null && widget.width == null
                            ? const EdgeInsets.symmetric(horizontal: 5.85)
                            : null,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: color, borderRadius: widget.borderRadius),
                        child: DefaultTextStyle.merge(
                            style: const TextStyle(
                                color: PanelStyles.textColor,
                                fontVariations: [FontVariation.weight(800)],
                                shadows: [Shadow(color: Color(0x35000000), offset: Offset(2.5, 2.5))]),
                            child: widget.child ?? Container()))))));
  }
}