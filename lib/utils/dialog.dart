import 'package:cd_mobile/utils/overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class GameDialog extends StatefulWidget {
  GameDialog({required this.title, super.key});

  OverlayEntry? entry;
  final String title;

  show() {
    entry = OverlayEntry(builder: (ct) => this);
    addOverlay(entry!);
  }

  onClose() {
    entry?.remove();
    entry?.dispose();
    entry = null;
  }

  @override
  State<GameDialog> createState() => _GameDialogState();
}

class _GameDialogState extends State<GameDialog> with SingleTickerProviderStateMixin {
  late final AnimationController animController;

  late final Animation<double> bgAnimation;

  late final Animation<Offset> dialogAnimation;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 210));
    bgAnimation = CurvedAnimation(parent: animController, curve: Curves.easeInOut);
    dialogAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(bgAnimation);

    animController.forward();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isHover = false;
    return FadeTransition(
        opacity: bgAnimation,
        child: Container(
            alignment: Alignment.center,
            color: const Color.fromRGBO(0, 0, 0, 0.55),
            height: context.height,
            width: context.width,
            child: SlideTransition(
              position: dialogAnimation,
              child: DefaultTextStyle(
                  style: const TextStyle(fontFamily: 'Nunito-var'),
                  child: Stack(children: [
                    Container(
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(12, 44, 150, 0.75),
                            boxShadow: const [
                              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 50)
                            ],
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // title
                            Padding(
                                padding: const EdgeInsets.only(top: 13.5, left: 13.5, right: 13.5),
                                child: Text(widget.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 27,
                                        fontVariations: [FontVariation('wght', 750)])))
                            // content
                          ],
                        )),
                    Positioned(
                        top: 0,
                        right: 8,
                        child: GestureDetector(
                            onTap: () {
                              animController.reverse().then((_) {
                                widget.onClose();
                              });
                            },
                            child: StatefulBuilder(
                                builder: (ct, setState) => MouseRegion(
                                    onEnter: (_) => setState(() {
                                          isHover = true;
                                        }),
                                    onExit: (_) => setState(() {
                                          isHover = false;
                                        }),
                                    child: Text('×',
                                        style: TextStyle(
                                            fontSize: 40.5,
                                            color: isHover
                                                ? Colors.white
                                                : const Color.fromRGBO(170, 170, 170, 1),
                                            height: 1,
                                            // fontWeight: FontWeight.w800
                                            fontVariations: const [FontVariation('wght', 850)]))))))
                  ])),
            )));
  }
}
