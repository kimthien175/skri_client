import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverlayController extends GetxController {
  OverlayController(this.builder);

  String get tag => _child.hashCode.toString();

  final Widget Function() builder;
  Widget? _child;

  OverlayEntry? _entry;
  bool get isShowing => _entry != null;

  bool show() {
    if (_entry != null) return false;

    _child = builder();

    Get.put(this, tag: tag);

    _entry = OverlayEntry(builder: (ct) => _child!);

    final overlayState = Navigator.of(Get.overlayContext!, rootNavigator: false).overlay!;

    overlayState.insert(_entry!);

    return true;
  }

  void hide() {
    if (_entry == null) return;

    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}

mixin OverlayWidgetMixin<T extends OverlayController> on Widget {
  T get controller => Get.find<OverlayController>(tag: hashCode.toString()) as T;
}
