import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

class HoverButton extends StatelessWidget {
  const HoverButton(
      {super.key,
      required this.child,
      this.color = GlobalStyles.colorPanelButton,
      this.hoverColor = GlobalStyles.colorPanelButtonHover,
      this.onTap,
      this.borderRadius = GlobalStyles.borderRadius,
      this.height,
      this.width});

  final Widget child;
  final Color color;
  final Color hoverColor;
  final void Function()? onTap;
  final BorderRadius borderRadius;

  final double? width;
  final double? height;

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
                    duration: AnimatedButton.duration,
                    height: height,
                    width: width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isHover ? hoverColor : color, borderRadius: borderRadius),
                    child: DefaultTextStyle(
                        style: const TextStyle(
                            shadows: [GlobalStyles.textShadow],
                            fontFamily: 'Nunito-var',
                            fontVariations: [FontVariation.weight(800)],
                            color: PanelStyles.textColor,
                            fontSize: 19.5),
                        child: child)))));
  }
}
