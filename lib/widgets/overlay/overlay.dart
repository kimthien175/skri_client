library overlay;

export 'loading.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'position.dart';

class OverlayController extends GetxController {
  OverlayController({this.widgetBuilder = OverlayController.defaultChildBuilder});

  static Widget defaultChildBuilder() =>
      throw Exception('Provide value or override getter for subclass');

  // OverlayWidget Function({required String tag, required Widget child}) get inheritedBuilder =>
  //     OverlayWidget._internal;

  final Widget Function() widgetBuilder;

  OverlayEntry? _entry;
  bool get isShowing => _entry != null;

  String get tag => hashCode.toString();

  Future<bool> show() async {
    if (_entry != null) return false;

    Get.put(this, tag: hashCode.toString());

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

  Future<bool> showOnce() async {
    if (isShowing) return false;
    return show();
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

class PositionedOverlayController<P extends OverlayWidgetPosition> extends OverlayController {
  PositionedOverlayController(
      {required this.childBuilder,
      required this.position,
      this.scale = PositionedOverlayController.defaultScaler,
      required this.anchorKey,
      this.tapOutsideToClose = false});

  @override
  Widget Function() get widgetBuilder =>
      () => OverlayWidget(controller: this, child: const _PositionedOverlayChildWidget());

  final Widget Function() childBuilder;
  final P position;
  final double Function() scale;

  final GlobalKey anchorKey;
  RenderBox get originalBox => anchorKey.currentContext!.findRenderObject() as RenderBox;

  static double defaultScaler() => 1.0;

  bool tapOutsideToClose;
}

class _PositionedOverlayChildWidget<T extends OverlayWidgetPosition> extends StatelessWidget {
  const _PositionedOverlayChildWidget({super.key});

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
          child: child,
        ));
  }
}
