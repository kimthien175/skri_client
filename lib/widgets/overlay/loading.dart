import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingState();
}

class _LoadingState extends State<LoadingIndicator> with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<double> animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  @override
  void initState() {
    super.initState();
    _controller
      ..forward()
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: animation,
        child: Stack(clipBehavior: Clip.none, children: [
          ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Image.asset(
                'assets/gif/load.gif',
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                width: 128,
                height: 128,
                fit: BoxFit.contain,
              )),
          Image.asset('assets/gif/load.gif',
              width: 128, height: 128, fit: BoxFit.contain, filterQuality: FilterQuality.none)
        ]));
  }
}

class LoadingOverlay extends OverlayController {
  static final LoadingOverlay _inst = LoadingOverlay._internal();
  static LoadingOverlay get inst => _inst;

  LoadingOverlay._internal() : super(builder: () => const _LoadingWidget());
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: const Color.fromRGBO(255, 255, 255, 0.2)))),
      const Center(child: LoadingIndicator())
    ]);
  }
}
