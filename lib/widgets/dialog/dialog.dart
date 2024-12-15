library dialog;

export 'buttons/buttons.dart';
export 'layout.dart';

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/dialog/render_object_widget.dart';
import 'package:skribbl_client/widgets/widgets.dart';

typedef StringCallback = String Function();

class GameDialog extends OverlayController with GetSingleTickerProviderStateMixin {
  /// `hide` parameter for `onQuit` is default to true for returning
  GameDialog(
      {required this.title,
      required this.content,
      this.exitTap = true,
      this.buttons,
      Future<bool> Function(Future<bool> Function() hide)? onQuit}) {
    this.onQuit = onQuit ??
        (_) async {
          await hide();
          return false;
        };
  }

  GameDialog.error({required this.content, RowRenderObjectWidget? buttons})
      : buttons = buttons ?? const RowRenderObjectWidget(children: [GameDialogButton.okay()]),
        title = Builder(builder: (context) => Text('dialog_title_error'.tr)),
        exitTap = false;

  factory GameDialog.cacheError({required dynamic error}) => GameDialog.cache(
      tag: error.toString(), builder: () => GameDialog.error(content: Text(error.toString())));

  @override
  Widget Function() get widgetBuilder => () => const _Dialog();

  static final Map<String, GameDialog> _cache = <String, GameDialog>{};

  factory GameDialog.cache({required String tag, required GameDialog Function() builder}) =>
      _cache.putIfAbsent(tag, builder);

  final Widget title;
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
    focusNode.requestScopeFocus();
  }

  // buttons null, layout null: ok button
  // layout null, buttons length ==1
  // layout != null, buttons length >1
  // final GameDialogButtonsLayout Function() layout;
  final RowRenderObjectWidget? buttons;

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

  late Completer<bool> completer;

  @override
  Future<bool> show() async {
    if (await super.show()) {
      await animController.forward();
      focusNode.requestFocus();
      completer = Completer();
      return completer.future;
    }
    throw Exception('dialog failed');
  }

  @override
  Future<bool> hide() async {
    focusNode.unfocus();
    await animController.reverse();
    return super.hide();
  }

  late final Future<bool> Function(Future<bool> Function() hide) onQuit;
}

class _Dialog extends StatelessWidget {
  const _Dialog();

  @override
  Widget build(BuildContext context) {
    GameDialog c = OverlayWidget.of<GameDialog>(context);
    Widget dialog = Stack(children: [
      Container(
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(minWidth: 410),
          decoration: const BoxDecoration(
              color: Color.fromRGBO(12, 44, 150, 0.75),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: DialogRenderObjectWidget(
            children: [
              const _Title(),
              Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 100),
                  child: c.content),
              if (c.buttons != null) c.buttons!
            ],
          )),
      const _CloseButton()
    ]);

    // SlideTransition(
    //     position: c.dialogAnimation,
    //     child: DefaultTextStyle(
    //         style: const TextStyle(
    //             fontFamily: 'Nunito-var',
    //             color: GlobalStyles.colorPanelText,
    //             fontVariations: [FontVariation('wght', 500)]),
    //         textAlign: TextAlign.center,
    //         child: BackdropFilter(
    //             filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
    //             child: Container(
    //                 constraints: BoxConstraints(minHeight: 100, minWidth: 100),
    //                 color: Colors.amber,
    //                 child: Stack(children: [
    //                   Container(height: 200, width: 200, color: Colors.pink),
    //                 ])))));

    if (c.exitTap) {
      dialog = TapRegion(
          onTapOutside: (event) {
            c.onQuit(c.hide);
          },
          child: dialog);
    }

    return FocusScope(
        node: c.focusNode,
        child: FadeTransition(
            opacity: c.bgAnimation,
            child:
                // fade background
                BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints.expand(),
                        color: const Color.fromRGBO(0, 0, 0, 0.55),
                        child:
                            // dialog
                            SlideTransition(
                                position: c.dialogAnimation,
                                child: DefaultTextStyle(
                                    style: const TextStyle(
                                        fontFamily: 'Nunito-var',
                                        color: GlobalStyles.colorPanelText,
                                        fontVariations: [FontVariation.weight(500)]),
                                    child: dialog))))));
  }
}

class _CloseButton extends StatefulWidget {
  const _CloseButton();
  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(duration: AnimatedButton.duration, vsync: this);
  late final Animation<Color?> colorAnim =
      ColorTween(begin: const Color.fromRGBO(170, 170, 170, 1), end: Colors.white)
          .animate(controller);

  late final FocusNode focusNode;
  @override
  void initState() {
    super.initState();

    focusNode = FocusNode(onKeyEvent: (node, key) {
      if (key is KeyDownEvent) {
        if (key.logicalKey == LogicalKeyboardKey.enter) {
          var c = OverlayWidget.of<GameDialog>(context);
          c.completer.complete(c.onQuit(c.hide));
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var c = OverlayWidget.of<GameDialog>(context);
    return Positioned(
        right: 8,
        top: 0,
        child: Focus(
            focusNode: focusNode,
            child: GestureDetector(
                onTap: () => c.completer.complete(c.onQuit(c.hide)),
                child: MouseRegion(
                    onEnter: (_) => controller.forward(),
                    onExit: (_) => controller.reverse(),
                    child: AnimatedBuilder(
                        animation: colorAnim,
                        builder: (ct, child) => Text('×',
                            style: TextStyle(
                                fontSize: 40.5,
                                color: colorAnim.value,
                                height: 1,
                                fontVariations: const [FontVariation('wght', 850)])))))));
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    var c = OverlayWidget.of<GameDialog>(context);
    return Padding(
        padding: const EdgeInsets.only(top: 3.5, left: 13.5, right: 40),
        child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 27, fontVariations: [FontVariation('wght', 750)]),
            child: c.title));
  }
}

/*Container(
                      constraints: const BoxConstraints(minHeight: 120, minWidth: 410),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color.fromRGBO(12, 44, 150, 0.75),
                          boxShadow: [
                            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 50)
                          ]),
                      child: Column(
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // title

                            // content
                            // Container(
                            //     alignment: Alignment.center,
                            //     //      constraints: const BoxConstraints(minWidth: 410, minHeight: 100),
                            //     padding: const EdgeInsets.only(
                            //         top: 7.5, left: 15, right: 15, bottom: 15),
                            //     child: DefaultTextStyle.merge(
                            //         style: const TextStyle(fontSize: 15), child: c.content)),
                            //  if (c.buttons != null) c.buttons!

              // child: Column(children: [
              //   Container(
              //       constraints: BoxConstraints(minHeight: 120),
              //       //     const Size(410, 120)), //height: 120, width: 410),
              //       //   height: 120,
              //       alignment: Alignment.center,
              //       child: DefaultTextStyle.merge(
              //           style: const TextStyle(fontSize: 15),
              //           child: c.content)),
              //   //  c._buttons
*/

