library;

export 'loading.dart';
export 'tooltip.dart';
export 'game_tooltip.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class OverlayController extends GetxController {
  OverlayController();

  /// init resources in constructor, not onInit, in case controller is called when needed,
  /// not put in page binding
  @nonVirtual
  @override
  void onInit() {
    super.onInit();
  }

  static double Function(BuildContext context) scale = (_) => 1.0;

  static final Map<String, OverlayController> _cache = <String, OverlayController>{};

  static P cache<P extends OverlayController>({
    required String tag,
    bool permanent = false,
    required P Function() builder,
  }) {
    P? found = _cache[tag] as P?;
    if (found != null) return found;

    var newController = builder();
    newController
      .._tag = tag
      .._permanent = permanent;

    _cache[tag] = newController;
    return newController;
  }

  static P? get<P extends OverlayController>(String tag) => _cache[tag] as P?;

  static Future<void> deleteCache(String tag) async {
    var controller = _cache.remove(tag);
    if (controller != null) {
      if (controller.isShowing) await controller.hide();
      Get.delete<OverlayController>(tag: tag, force: true);
    }
  }

  /// call once when showing, not function as re render in command
  Widget widgetBuilder();

  OverlayEntry? _entry;
  bool get isShowing => _entry != null;

  String? _tag;
  String get tag => _tag ?? hashCode.toString();
  bool? _permanent;

  Future<bool> show() async {
    if (_entry != null) return false;

    Get.put(this, tag: tag, permanent: _permanent ?? false);

    _entry = OverlayEntry(
      builder: (ct) => OverlayWidget(controller: this, child: widgetBuilder()),
    );

    final overlayState = Navigator.of(Get.overlayContext!, rootNavigator: false).overlay!;

    overlayState.insert(_entry!);

    return true;
  }

  Future<bool> hide() async {
    if (_entry == null) return false;

    _entry?.remove();
    _entry?.dispose();
    _entry = null;

    return true;
  }

  @override
  void onClose() {
    if (_entry != null) {
      _entry?.remove();
      _entry?.dispose();
    }
    super.onClose();

    _cache.remove(_tag);
  }
}

class OverlayWidget extends InheritedWidget {
  const OverlayWidget({super.key, required super.child, required this.controller});

  final OverlayController controller;

  static T? of<T extends OverlayController>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OverlayWidget>()?.controller as T?;

  @override
  bool updateShouldNotify(covariant OverlayWidget oldWidget) => oldWidget.controller != controller;
}
