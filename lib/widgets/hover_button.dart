import 'package:flutter/material.dart';

class HoverButton extends StatelessWidget {
  const HoverButton(
      {super.key,
      required this.child,
      required this.color,
      required this.hoverColor,
      this.onTap,
      this.borderRadius = BorderRadius.zero,
      this.height = double.infinity,
      this.width = double.infinity});

  final Widget child;
  final Color color;
  final Color hoverColor;
  final void Function()? onTap;
  final BorderRadius borderRadius;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    var isHover = false;
    return StatefulBuilder(
        builder: (ct, setState) => MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              setState(() {
                isHover = true;
              });
            },
            onExit: (_) {
              setState(() {
                isHover = false;
              });
            },
            child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                    height: height,
                    width: width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isHover ? hoverColor : color, borderRadius: borderRadius),
                    child: child))));
  }
}
