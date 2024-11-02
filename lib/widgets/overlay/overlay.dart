import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'position.dart';

class OverlayController extends GetxController {
  OverlayController({this.builder = OverlayController.defaultBuilder});

  static Widget defaultBuilder() =>
      throw Exception('Provide value or override getter for subclass');

  final Widget Function() builder;

  OverlayEntry? _entry;
  bool get isShowing => _entry != null;

  String? _tag;
  String get tag => _tag!;

  Future<bool> show() async {
    if (_entry != null) return false;

    var child = builder();

    _tag = child.hashCode.toString();

    Get.lazyPut(() => this, tag: _tag);
    _entry = OverlayEntry(builder: (ct) => child);

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

mixin OverlayWidgetMixin<T extends OverlayController> on Widget {
  T get controller => Get.find<OverlayController>(tag: hashCode.toString()) as T;
}

abstract class PositionedOverlayWidget<T extends OverlayController> extends StatelessWidget {
  const PositionedOverlayWidget(this.tag, {super.key});
  final String tag;
  T get controller => Get.find<OverlayController>(tag: tag) as T;
}

class PositionedOverlayController<T extends OverlayWidgetPosition> extends OverlayController {
  PositionedOverlayController(
      {required this.childBuilder,
      required this.position,
      this.scale = PositionedOverlayController.defaultScaler,
      required this.anchorKey,
      this.tapOutsideToClose = false});

  @override
  Widget Function() get builder => () => const _PositionedOverlayWidgetWrapper();

  final Widget Function(String tag) childBuilder;
  final T position;
  final double Function() scale;

  final GlobalKey anchorKey;
  RenderBox get originalBox => anchorKey.currentContext!.findRenderObject() as RenderBox;

  static double defaultScaler() => 1.0;

  bool tapOutsideToClose;
}

class _PositionedOverlayWidgetWrapper<T extends OverlayWidgetPosition> extends StatelessWidget
    with OverlayWidgetMixin<PositionedOverlayController> {
  const _PositionedOverlayWidgetWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    var child = controller.childBuilder(controller.tag);

    if (controller.tapOutsideToClose) {
      child = TapRegion(
        onTapOutside: (PointerDownEvent event) {
          controller.hide();
        },
        child: child,
      );
    }

    return controller.position.build(
        originalBox: controller.originalBox,
        scale: controller.scale(),
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
