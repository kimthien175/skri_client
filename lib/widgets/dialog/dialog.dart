library;

export 'buttons/buttons.dart';

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';

part 'render_object_widget.dart';

typedef StringCallback = String Function();

typedef OnQuitCallback = Future<bool> Function(Future<bool> Function() hide);

class GameDialog extends OverlayController with GetSingleTickerProviderStateMixin {
  static const double minWidth = 390;
  static const double padding = 10;

  /// `hide` parameter for `onQuit` is default to true for returning
  GameDialog(
      {required this.title,
      required Widget content,
      this.exitTap = true,
      RowRenderObjectWidget? buttons,
      this.onQuit = GameDialog.onQuitDefault})
      : content = content.obs,
        buttons = buttons.obs {
    assert(content is! Center);
    _init();
  }

  static Future<bool> onQuitDefault(Future<bool> Function() hide) async {
    await hide();
    return false;
  }

  GameDialog.error(
      {required Widget content,
      RowRenderObjectWidget buttons =
          const RowRenderObjectWidget(children: [GameDialogButton.okay()]),
      this.onQuit = GameDialog.onQuitDefault})
      : title = Builder(builder: (context) => Text('dialog_title_error'.tr)),
        exitTap = false,
        content = content.obs,
        buttons = buttons.obs {
    assert(content is! Center);
    _init();
  }

  GameDialog.discconected(
      {required Widget content,
      RowRenderObjectWidget buttons =
          const RowRenderObjectWidget(children: [GameDialogButton.okay()]),
      this.onQuit = GameDialog.onQuitDefault})
      : title = Builder(builder: (_) => Text('dialog_title_disconnected'.tr)),
        exitTap = false,
        content = content.obs,
        buttons = buttons.obs {
    assert(content is! Center);
    _init();
  }

  @override
  Widget widgetBuilder() => const _Dialog();

  final Widget title;
  final Rx<Widget> content;

  final bool exitTap;

  late final AnimationController animController;

  late final Animation<double> bgAnimation;

  late final Animation<Offset> dialogAnimation;

  late final FocusScopeNode focusNode;

  void _init() {
    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 210));

    bgAnimation = CurvedAnimation(parent: animController, curve: Curves.easeInOut);

    dialogAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(bgAnimation);

    focusNode = FocusScopeNode(onKeyEvent: _keyHandler);
  }

  // buttons null, layout null: ok button
  // layout null, buttons length ==1
  // layout != null, buttons length >1
  // final GameDialogButtonsLayout Function() layout;
  final Rx<RowRenderObjectWidget?> buttons;

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
      completer = Completer<bool>();

      await animController.forward();

      focusNode.requestScopeFocus();
      focusNode.requestFocus();

      return completer.future;
    }
    return false;
  }

  @override
  Future<bool> hide() async {
    if (!isShowing || animController.velocity < 0) return false;

    focusNode.unfocus();
    await animController.reverse();
    return super.hide();
  }

  Future<bool> showInstantly() async {
    if (await super.show()) {
      completer = Completer<bool>();
      animController.value = 1;
      focusNode.requestScopeFocus();
      focusNode.requestFocus();

      return completer.future;
    }
    return false;
  }

  Future<bool> hideInstantly() async {
    focusNode.unfocus();
    return super.hide();
  }

  late final Future<bool> Function(Future<bool> Function() hide) onQuit;
}

class _Dialog extends StatelessWidget {
  const _Dialog();

  @override
  Widget build(BuildContext context) {
    GameDialog c = OverlayWidget.of<GameDialog>(context)!;
    Widget dialog = Stack(children: [
      Container(
          padding: const EdgeInsets.all(GameDialog.padding),
          constraints: const BoxConstraints(minWidth: GameDialog.minWidth + GameDialog.padding * 2),
          decoration: const BoxDecoration(
              color: Color.fromRGBO(12, 44, 150, 0.75),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Obx(() {
            var buttons = c.buttons.value;
            return _DialogRenderObjectWidget(children: [
              const _Title(),
              Padding(padding: EdgeInsets.only(bottom: 10), child: c.content.value),
              if (buttons != null) buttons
            ]);
          })),
      const _CloseButton()
    ]);

    if (c.exitTap) {
      dialog = TapRegion(
          onTapOutside: (event) {
            if (c.completer.isCompleted || c.animController.velocity < 0) return;
            c.completer.complete(c.onQuit(c.hide));
          },
          child: dialog);
    }

    var scale = OverlayController.scale(context);

    if (scale != 1) {
      dialog = Transform.scale(scale: scale, child: dialog);
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
          var c = OverlayWidget.of<GameDialog>(context)!;
          if (c.completer.isCompleted || c.animController.velocity < 0) {
            return KeyEventResult.ignored;
          }
          c.completer.complete(c.onQuit(c.hide));
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.forward();
      } else {
        controller.reverse();
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
    var c = OverlayWidget.of<GameDialog>(context)!;
    return Positioned(
        right: 8,
        top: 0,
        child: Focus(
            focusNode: focusNode,
            child: GestureDetector(
                onTap: () {
                  if (c.completer.isCompleted || c.animController.velocity < 0) return;
                  c.completer.complete(c.onQuit(c.hide));
                },
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
    var c = OverlayWidget.of<GameDialog>(context)!;
    return Padding(
        padding: const EdgeInsets.only(top: 3.5, left: 13.5, right: 40),
        child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 27, fontVariations: [FontVariation('wght', 750)]),
            child: c.title));
  }
}
