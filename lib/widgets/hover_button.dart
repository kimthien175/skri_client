import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

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
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          controller.forward();
        },
        onExit: (_) {
          controller.reverse();
        },
        child: GestureDetector(
            onTap: widget.onTap,
            child: BackgroundColorTransition(
                height: widget.height,
                width: widget.width,
                borderRadius: widget.borderRadius,
                listenable:
                    ColorTween(begin: widget.color, end: widget.hoverColor).animate(controller),
                child: widget.child)));
  }
}
