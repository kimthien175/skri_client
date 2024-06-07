import 'dart:math';
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
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.addListener(() {
      if (_controller.isCompleted) _controller.repeat();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: Tween<double>(begin: 0, end: 1).animate(_controller),
        child: Image.asset('assets/gif/load.gif'));
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    double size = min(Get.width, Get.height) * 0.2;
    return Stack(children: [
      Positioned.fill(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withOpacity(0)))),
      Center(child: SizedBox(height: size, width: size, child: const FittedBox(child: Loading())))
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
