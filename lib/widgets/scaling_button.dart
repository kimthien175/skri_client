import 'package:flutter/material.dart';

// TODO: tool tip
class ScalingButton extends StatefulWidget {
  const ScalingButton({required this.child, this.onTap, super.key});

  final Widget child;
  final Function()? onTap;
  @override
  State<ScalingButton> createState() => _ScaleTransitionExampleState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _ScaleTransitionExampleState extends State<ScalingButton> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, lowerBound: 0.9, upperBound: 1);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
            onEnter: (e) => _controller.forward(),
            onExit: (e) => _controller.reverse(),
            child: ScaleTransition(
              scale: _animation,
              child: widget.child,
            )));
  }
}
