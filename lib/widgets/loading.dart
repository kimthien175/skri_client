import 'dart:ui';

import 'package:cd_mobile/utils/overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
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

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: const Color.fromRGBO(255, 255, 255, 0.2)))),
      const Center(child: Loading())
    ]);
  }
}

class LoadingManager extends GetxController {
  LoadingManager._internal();
  static final LoadingManager _inst = LoadingManager._internal();
  static LoadingManager get inst => _inst;

  OverlayEntry? _entry;
  bool get isLoading => _entry != null;
  void show() {
    if (isLoading) return;
    _entry = OverlayEntry(builder: (ct) => const LoadingOverlay());
    addOverlay(_entry!);
  }

  void hide() {
    if (!isLoading) return;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}
