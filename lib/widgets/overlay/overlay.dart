library;

export 'loading.dart';
export 'tooltip.dart';
export 'game_tooltip.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class OverlayController extends GetxController {
  OverlayController() {
    _entry = OverlayEntry(
      builder: (ct) => OverlayWidget(controller: this, child: widgetBuilder()),
    );
  }

  /// init resources in constructor, not onInit, in case controller is called when needed,
  /// not put in page binding
  @nonVirtual
  @override
  void onInit() {
    super.onInit();
  }

  static double Function(BuildContext context) scale = (_) => 1.0;

  static final Map<String, OverlayController> _cache = <String, OverlayController>{};

  static P put<P extends OverlayController>({
    required String tag,
    bool permanent = false,
    required P Function() builder,
  }) {
    P? found = _cache[tag] as P?;
    if (found != null) return found;

    var newController = builder();
    Get.put(newController, tag: tag, permanent: permanent);
    newController._tag = tag;

    _cache[tag] = newController;
    return newController;
  }

  String? _tag;

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

  late final OverlayEntry _entry;
  bool get isShowing => _isShowing;
  bool _isShowing = false;

  Future<bool> show() async {
    if (isShowing) return false;

    _isShowing = true;

    final overlayState = Navigator.of(Get.overlayContext!, rootNavigator: false).overlay!;

    overlayState.insert(_entry);

    return true;
  }

  Future<bool> hide() async {
    if (!isShowing) return false;

    _entry.remove();

    _isShowing = false;
    return true;
  }

  @override
  void onClose() {
    hide();
    _entry.dispose();

    _cache.remove(_tag);

    super.onClose();
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
