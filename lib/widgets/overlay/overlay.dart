library;

export 'loading.dart';
export 'tooltip.dart';
export 'game_tooltip.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class OverlayController extends GetxController {
  OverlayController({this.permanent = false});

  static double Function(BuildContext context) scale = (_) => 1.0;

  // static Widget defaultChildBuilder() =>
  //     throw Exception('Provide value or override getter for subclass');

  static final Map<String, OverlayController> _cache = <String, OverlayController>{};

  static P cache<P extends OverlayController>(
      {required String tag, required P Function() builder}) {
    var inst = _cache.putIfAbsent(tag, builder) as P;
    inst.cachedTag = tag;
    return inst;
  }

  static P? get<P extends OverlayController>(String tag) => _cache[tag] as P?;

  static Future<void> deleteCache(String tag) async {
    var controller = _cache.remove(tag);
    if (controller != null) {
      if (controller.isShowing) await controller.hide();
      Get.delete<OverlayController>(tag: tag, force: true);
    }
  }

  String? cachedTag;

  /// call once when showing, not function as re render in command
  Widget widgetBuilder();

  OverlayEntry? _entry;
  bool get isShowing => _entry != null;

  String get tag => cachedTag ?? hashCode.toString();

  final bool permanent;

  Future<bool> show() async {
    if (_entry != null) return false;

    Get.put(this, tag: tag, permanent: permanent);

    _entry = OverlayEntry(builder: (ct) => OverlayWidget(controller: this, child: widgetBuilder()));

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

    _cache.remove(tag);
  }
}

class OverlayWidget extends InheritedWidget {
  const OverlayWidget({super.key, required super.child, required this.controller});

  final OverlayController controller;

  static T of<T extends OverlayController>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OverlayWidget>()!.controller as T;

  @override
  bool updateShouldNotify(covariant OverlayWidget oldWidget) => oldWidget.controller != controller;
}
