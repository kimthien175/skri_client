import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class GameDialog extends OverlayController with GetSingleTickerProviderStateMixin {
  GameDialog({required this.title, required this.content, this.exitTap = true})
      : super(() => const _Dialog());

  final String Function() title;
  final Widget content;

  final bool exitTap;

  late final AnimationController animController;

  late final Animation<double> bgAnimation;

  late final Animation<Offset> dialogAnimation;

  late final FocusScopeNode focusNode;

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 210));

    bgAnimation = CurvedAnimation(parent: animController, curve: Curves.easeInOut);

    dialogAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(bgAnimation);

    focusNode = FocusScopeNode(onKeyEvent: _keyHandler);
  }

  @override
  void onClose() {
    animController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  KeyEventResult _keyHandler(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        hide();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  bool show() {
    if (super.show()) {
      animController.forward().then((_) {
        focusNode.requestFocus();
      });
      return true;
    }
    return false;
  }

  @override
  void hide() {
    focusNode.unfocus();
    animController.reverse().then((_) {
      super.hide();
    });
  }
}

class _Dialog extends StatelessWidget with OverlayWidgetMixin<GameDialog> {
  const _Dialog();

  @override
  Widget build(BuildContext context) {
    var c = controller;
    final dialog = SlideTransition(
        position: c.dialogAnimation,
        child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Nunito-var', color: Colors.white),
            child: Stack(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(12, 44, 150, 0.75),
                              boxShadow: [
                                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 50)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // title
                                Padding(
                                    padding:
                                        const EdgeInsets.only(top: 13.5, left: 13.5, right: 40),
                                    child: Text(c.title(),
                                        style: const TextStyle(
                                            fontSize: 27,
                                            fontVariations: [FontVariation('wght', 750)]))),
                                // content
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 7.5, left: 15, right: 15, bottom: 15),
                                    child: c.content)
                              ])))),
              Positioned(
                  top: 0, right: 8, child: GestureDetector(onTap: c.hide, child: _CloseIcon()))
            ])));

    return FocusScope(
        node: c.focusNode,
        child: FadeTransition(
            opacity: c.bgAnimation,
            child: c.exitTap
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                          onTap: c.hide,
                          child: Container(
                            constraints: const BoxConstraints.expand(),
                            alignment: Alignment.center,
                            color: const Color.fromRGBO(0, 0, 0, 0.55),
                          )),
                      dialog
                    ],
                  )
                : Container(
                    constraints: const BoxConstraints.expand(),
                    alignment: Alignment.center,
                    color: const Color.fromRGBO(0, 0, 0, 0.55),
                    child: dialog)));
  }
}

class _CloseIcon extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CloseIconState();
}

class _CloseIconState extends State<_CloseIcon> with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(duration: AnimatedButton.duration, vsync: this);
  late final Animation<Color?> colorAnim =
      ColorTween(begin: const Color.fromRGBO(170, 170, 170, 1), end: Colors.white)
          .animate(controller);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) => controller.forward(),
        onExit: (_) => controller.reverse(),
        child: AnimatedBuilder(
            animation: colorAnim,
            builder: (ct, child) => Text('×',
                style: TextStyle(
                    fontSize: 40.5,
                    color: colorAnim.value,
                    height: 1,
                    fontVariations: const [FontVariation('wght', 850)]))));
  }
}
