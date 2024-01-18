import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameFooter extends StatelessWidget {
  const GameFooter({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GameFooterController>();
    return Container(
        width: 800,
        alignment: Alignment.center,
        child: Obx(
          () => controller.child.value,
        ));
  }
}

class GameFooterController extends GetxController {
  GameFooterController() {
    child = _emptyWidget.obs;
  }
  late Rx<Widget> child;
  // casting to make getx understand thats a observable Widget, not a observable Container
  // ignore: unnecessary_cast
  final Widget _emptyWidget = Container() as Widget;
  empty() {
    child.value = _emptyWidget;
  }
}
