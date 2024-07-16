import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

mixin GameOverlay on Widget {
  OverlayEntry? _entry;

  bool get isShowing => _entry != null;

  show() {
    if (_entry != null) return;

    _entry = OverlayEntry(builder: (ct) => this);
    final overlayState = Navigator.of(Get.overlayContext!, rootNavigator: false).overlay!;

    overlayState.insert(_entry!);
  }

  hide() {
    if (_entry == null) return;

    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}

// ignore: must_be_immutable
class GameDialog extends StatefulWidget with GameOverlay {
  GameDialog({required this.title, required this.content, super.key, this.exitTap = false});

  final String Function() title;
  final Widget content;

  final bool exitTap;

  @override
  State<GameDialog> createState() => _GameDialogState();
}

class _GameDialogState extends State<GameDialog> with SingleTickerProviderStateMixin {
  late final AnimationController animController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 210));

  late final Animation<double> bgAnimation =
      CurvedAnimation(parent: animController, curve: Curves.easeInOut);

  late final Animation<Offset> dialogAnimation =
      Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(bgAnimation);

  @override
  void initState() {
    super.initState();
    animController.forward();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  close() {
    animController.reverse().then((_) {
      widget.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dialog = SlideTransition(
        position: dialogAnimation,
        child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Nunito-var'),
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
                                    child: Text(widget.title(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 27,
                                            fontVariations: [FontVariation('wght', 750)]))),
                                // content
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 7.5, left: 15, right: 15, bottom: 15),
                                    child: widget.content)
                              ])))),
              Positioned(
                  top: 0, right: 8, child: GestureDetector(onTap: close, child: _CloseIcon()))
            ])));

    return FadeTransition(
        opacity: bgAnimation,
        child: widget.exitTap
            ? Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                      onTap: close,
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
                child: dialog));
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
