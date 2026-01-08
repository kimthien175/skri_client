import 'package:flutter/services.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/color_transition.dart';

class HoverButton extends StatefulWidget {
  const HoverButton({
    super.key,
    this.child,
    this.color = GlobalStyles.colorPanelButton,
    this.hoverColor = GlobalStyles.colorPanelButtonHover,
    this.onTap,
    this.borderRadius = GlobalStyles.borderRadius,
    this.height,
    this.width,
    this.constraints,
    this.isDisabled = false,
    this.controller,
    this.border,
    this.autoFocus = false,
  });

  final Widget? child;
  final Color color;
  final Color hoverColor;
  final void Function()? onTap;
  final BorderRadius? borderRadius;

  final double? width;
  final double? height;

  final BoxConstraints? constraints;
  final bool isDisabled;

  final AnimationController? controller;

  final Border? border;

  final bool autoFocus;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final FocusNode focusNode;

  late final Animation<Color?> backgroundListenable;
  late final Animation<Color?>? borderListenable;

  late final EdgeInsetsGeometry? padding = widget.height == null && widget.width == null
      ? const EdgeInsets.symmetric(horizontal: 5.85)
      : null;

  bool isHovered = false;

  late bool autoFocus;

  @override
  void didUpdateWidget(HoverButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoFocus != autoFocus) {
      setState(() => autoFocus = widget.autoFocus);
    }
  }

  @override
  void initState() {
    super.initState();

    controller =
        widget.controller ?? AnimationController(vsync: this, duration: AnimatedButton.duration);

    backgroundListenable = ColorTween(
      begin: widget.color,
      end: widget.hoverColor,
    ).animate(controller);

    borderListenable = widget.border == null
        ? ColorTween(
            begin: widget.color,
            end: Color.alphaBlend(Colors.white.withValues(alpha: 0.6), widget.color),
          ).animate(controller)
        : null;

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

    autoFocus = widget.autoFocus;
    if (autoFocus) {
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDisabled) {
      return Container(
        constraints: widget.constraints,
        height: widget.height,
        width: widget.width,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color.alphaBlend(Colors.black.withValues(alpha: 0.2), widget.color),
          borderRadius: widget.borderRadius,
          border: widget.border,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: Color.alphaBlend(Colors.black.withValues(alpha: 0.2), PanelStyles.textColor),
            fontVariations: [FontVariation.weight(800)],
            shadows: [Shadow(color: Color(0x35000000), offset: Offset(2.5, 2.5))],
          ),
          child: widget.child ?? Container(),
        ),
      );
    }

    final lowLevelChild = DefaultTextStyle.merge(
      style: const TextStyle(
        color: PanelStyles.textColor,
        fontVariations: [FontVariation.weight(800)],
        shadows: [Shadow(color: Color(0x35000000), offset: Offset(2.5, 2.5))],
      ),
      child: widget.child ?? Container(),
    );

    final child = (borderListenable != null)
        ? ColorTransition(
            listenable: borderListenable!,
            builder: (borderColor) => ColorTransition(
              listenable: backgroundListenable,
              builder: (color) => Container(
                constraints: widget.constraints,
                height: widget.height,
                width: widget.width,
                padding: padding,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: widget.borderRadius,
                  border: BoxBorder.all(width: 2.0, color: borderColor),
                ),
                child: lowLevelChild,
              ),
            ),
          )
        : ColorTransition(
            listenable: backgroundListenable,
            builder: (color) => Container(
              constraints: widget.constraints,
              height: widget.height,
              width: widget.width,
              padding: padding,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: widget.borderRadius,
                border: widget.border,
              ),
              child: lowLevelChild,
            ),
          );

    return Focus(
      autofocus: autoFocus,
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
        child: GestureDetector(onTap: widget.onTap, child: child),
      ),
    );
  }
}
