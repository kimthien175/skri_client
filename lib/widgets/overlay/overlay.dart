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

    Get.lazyPut(() => this, tag: tag);
    _entry = OverlayEntry(builder: (ct) => OverlayWidget(tag: tag, child: widgetBuilder()));

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
    hide();
    super.onClose();
  }

  @override
  void dispose() {
    hide();
    super.dispose();
  }
}

class OverlayWidget extends InheritedWidget {
  const OverlayWidget({super.key, required super.child, required this.tag});

  final String tag;

  static OverlayWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OverlayWidget>()!;

  @override
  bool updateShouldNotify(covariant OverlayWidget oldWidget) => oldWidget.tag != tag;
}

abstract class OverlayChildWidget<C extends OverlayController, W extends OverlayWidget>
    extends StatelessWidget {
  const OverlayChildWidget({super.key});

  C controller(BuildContext ct) => Get.find<OverlayController>(tag: OverlayWidget.of(ct).tag) as C;
}

class PositionedOverlayController<P extends OverlayWidgetPosition> extends OverlayController {
  PositionedOverlayController(
      {required this.childBuilder,
      required this.position,
      this.scale = PositionedOverlayController.defaultScaler,
      required this.anchorKey,
      this.tapOutsideToClose = false});

  @override
  Widget Function() get widgetBuilder => () => const _PositionedOverlayChildWidget();

  final Widget Function() childBuilder;
  final P position;
  final double Function() scale;

  final GlobalKey anchorKey;
  RenderBox get originalBox => anchorKey.currentContext!.findRenderObject() as RenderBox;

  static double defaultScaler() => 1.0;

  bool tapOutsideToClose;
}

class _PositionedOverlayChildWidget<T extends OverlayWidgetPosition>
    extends OverlayChildWidget<PositionedOverlayController, OverlayWidget> {
  const _PositionedOverlayChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var c = controller(context);
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
              fontWeight: FontWeight.w700,
              fontSize: 13.0,
              fontFamily: 'Nunito'),
          child: child,
        ));
  }
}
