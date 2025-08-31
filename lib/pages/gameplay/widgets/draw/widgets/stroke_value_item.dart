import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../manager.dart';

class StrokeValueItemController extends GetxController with GetSingleTickerProviderStateMixin {
  StrokeValueItemController(this.value) {
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.2))
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear));
  }
  late final AnimationController controller;
  late final Animation<Offset> _animation;

  var isHovered = false.obs;

  void hover() {
    isHovered.value = true;
    controller.forward();
  }

  void unHover() {
    controller.reverse();
    isHovered.value = false;
  }

  bool isEntered = false;

  RxDouble value;
}

class StrokeValueItem extends StatelessWidget {
  const StrokeValueItem(
      {required this.child,
      this.isMain = false,
      required this.onTap,
      super.key,
      required this.controller});

  final void Function() onTap;

  final StrokeValueItemController controller;

  static const double size = 48;

  final Widget child;

  final bool isMain;

  @override
  Widget build(BuildContext context) {
    var toolsInst = DrawManager.inst;
    var widget = isMain
        ? Obx(() => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: controller.isHovered.value
                    ? const Color.fromRGBO(76, 76, 76, 1)
                    : (DrawManager.inst.currentColor == Colors.white ? Colors.grey : Colors.white)),
            height: size,
            width: size,
            child: SlideTransition(position: controller._animation, child: child)))
        : Obx(
            () => Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: toolsInst.currentStrokeSize == controller.value.value
                        ? Colors.deepPurpleAccent
                        : controller.isHovered.value
                            ? const Color.fromRGBO(76, 76, 76, 1)
                            : (DrawManager.inst.currentColor == Colors.white
                                ? Colors.grey
                                : Colors.white)),
                height: size,
                width: size,
                child: SlideTransition(position: controller._animation, child: child)),
          );
    return InkWell(
        onTap: onTap,
        child: MouseRegion(
            opaque: false,
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              controller.hover();
            },
            onExit: (event) {
              controller.unHover();
            },
            child: widget));
  }
}
