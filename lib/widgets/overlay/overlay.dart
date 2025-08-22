library;

export 'loading.dart';
export 'position.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'position.dart';

abstract class OverlayController extends GetxController {
  // static Widget defaultChildBuilder() =>
  //     throw Exception('Provide value or override getter for subclass');

  static final Map<String, OverlayController> _cache = <String, OverlayController>{};

  static P cache<P extends OverlayController>(
      {required String tag, required P Function() builder}) {
    var inst = _cache.putIfAbsent(tag, builder) as P;
    inst.cachedTag = tag;
    return inst;
  }

  static deleteCache(String tag) {
    _cache.remove(tag);
    Get.delete<OverlayController>(tag: tag, force: true);
  }

  String? cachedTag;

  /// call once when showing, not function as re render in command
  Widget widgetBuilder();

  OverlayEntry? _entry;
  bool get isShowing => _entry != null;

  String get tag => cachedTag ?? hashCode.toString();

  Future<bool> show() async {
    if (_entry != null) return false;

    Get.put(this, tag: tag, permanent: cachedTag != null);

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

    // if (cachedTag == null) {
    //   Get.delete<OverlayController>(tag: tag);
    // }

    return true;
  }

  @override
  void onClose() {
    if (_entry != null) {
      _entry?.remove();
      _entry?.dispose();
    }
    super.onClose();
  }

  // Future<void> showOnce({void Function(bool value)? onDone}) async {
  //   assert(cachedTag != null);
  //   if (isShowing) return;
  //   var result = await show();
  //   if (onDone != null) onDone(result);
  // }
}

class OverlayWidget extends InheritedWidget {
  const OverlayWidget({super.key, required super.child, required this.controller});

  final OverlayController controller;

  static T of<T extends OverlayController>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OverlayWidget>()!.controller as T;

  @override
  bool updateShouldNotify(covariant OverlayWidget oldWidget) => oldWidget.controller != controller;
}

class PositionedOverlayController<P extends OverlayWidgetPosition> extends OverlayController {
  PositionedOverlayController(
      {required this.childBuilder,
      required this.position,
      this.scale = PositionedOverlayController.defaultScaler,
      required this.anchorKey,
      this.tapOutsideToClose = false});

  @override
  Widget widgetBuilder() => const _PositionedOverlayChildWidget();

  final Widget Function() childBuilder;
  final P position;
  final double Function() scale;

  final GlobalKey anchorKey;
  RenderBox get originalBox => anchorKey.currentContext!.findRenderObject() as RenderBox;

  static double defaultScaler() => 1.0;

  bool tapOutsideToClose;
}

class _PositionedOverlayChildWidget extends StatefulWidget {
  const _PositionedOverlayChildWidget();

  @override
  State<_PositionedOverlayChildWidget> createState() => __PositionedOverlayChildWidgetState();
}

class __PositionedOverlayChildWidgetState extends State<_PositionedOverlayChildWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var c = OverlayWidget.of<PositionedOverlayController>(context);

    var child = c.childBuilder();

    if (c.tapOutsideToClose) {
      child = TapRegion(
        onTapOutside: (PointerDownEvent event) {
          c.hide();
        },
        child: child,
      );
    }

    return c.position.build(
        originalBox: c.originalBox,
        scale: c.scale(),
        child: DefaultTextStyle(
            style: const TextStyle(
                color: Color.fromRGBO(240, 240, 240, 1),
                fontVariations: [FontVariation.weight(700)],
                fontSize: 13.0,
                fontFamily: 'Nunito-var'),
            child: child));
  }
}
