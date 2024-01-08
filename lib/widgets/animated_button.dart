import 'package:flutter/material.dart';

// TODO: tool tip
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({required this.child, this.onTap, this.minOpacity = 0.5, super.key});

  final Widget child;
  final Function()? onTap;

  final double minOpacity;

  @override
  State<AnimatedButton> createState() => _ScaleTransition();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _ScaleTransition extends State<AnimatedButton> with TickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: _duration, vsync: this, lowerBound: 0.9, upperBound: 1);
  final Duration _duration = const Duration(milliseconds: 130);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  bool _visible = false;
  late final Widget Function() _child;
  @override
  void initState() {
    super.initState();
    if (widget.minOpacity < 1) {
      _child = () => GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) {
                _controller.forward();
                setState(() => _visible = true);
              },
              onExit: (e) {
                _controller.reverse();
                setState(() => _visible = false);
              },
              child: ScaleTransition(
                scale: _animation,
                child: AnimatedOpacity(
                    opacity: _visible ? 1 : widget.minOpacity,
                    duration: _duration,
                    child: widget.child),
              )));
    } else {
      _child = () => GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => _controller.forward(),
              onExit: (e) => _controller.reverse(),
              child: ScaleTransition(
                scale: _animation,
                child: widget.child,
              )));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _child();
  }
}
