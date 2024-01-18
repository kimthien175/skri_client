import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';

/// START FADING IN ON FIRST SHOWING
class CanvasOverlay extends StatefulWidget {
  const CanvasOverlay({super.key});

  @override
  State<CanvasOverlay> createState() => _OverlayState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _OverlayState extends State<CanvasOverlay> with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> _animation;
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(controller);

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animation,
        child: Container(
          height: 600,
          width: 800,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(3, 8, 29, 0.8),
            borderRadius: GlobalStyles.borderRadius,
          ),
        ));
  }
}
