library dialog;

export 'button.dart';
export 'layout.dart';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../../utils/utils.dart';

typedef StringCallback = String Function();

class GameDialog extends OverlayController with GetSingleTickerProviderStateMixin {
  GameDialog({
    required this.title,
    required this.content,
    this.exitTap = true,
    // this.layout = GameDialogButtonsLayout.defaultOkay,
    // this.buttons
  }) : super(builder: () => const _Dialog());

  static final Map<String, GameDialog> _cache = <String, GameDialog>{};

  factory GameDialog.cache({required String tag, required GameDialog Function() builder}) =>
      _cache.putIfAbsent(tag, builder);

  final StringCallback title;
  final Widget content;

  final bool exitTap;

  late final AnimationController animController;

  late final Animation<double> bgAnimation;

  late final Animation<Offset> dialogAnimation;

  late final FocusScopeNode focusNode;

  /// buttons null: ok button
  /// layout null, buttons length ==1
  /// layout != null, buttons length >1
  // final GameDialogButtonsLayout Function() layout;
  // final List<GameDialogButton>? buttons;

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
  Future<bool> show() async {
    if (await super.show()) {
      await animController.forward();
      focusNode.requestFocus();

      return true;
    }
    return false;
  }

  @override
  Future<bool> hide() async {
    focusNode.unfocus();
    await animController.reverse();
    return super.hide();
  }
}

class _Dialog extends StatelessWidget with OverlayWidgetMixin<GameDialog> {
  const _Dialog();

  @override
  Widget build(BuildContext context) {
    var c = controller;
    Widget dialog = SlideTransition(
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
                                Container(
                                    width: 410,
                                    padding: const EdgeInsets.only(
                                        top: 7.5, left: 15, right: 15, bottom: 15),
                                    child: Column(children: [
                                      c.content,
                                      // DefaultTextStyle(
                                      //     style: const TextStyle(
                                      //       color: GlobalStyles.colorPanelText,
                                      //       fontSize: 15,
                                      //     ),
                                      //     child: c.layout())
                                    ])),
                              ])))),
              Positioned(
                  top: 0, right: 8, child: GestureDetector(onTap: c.hide, child: _CloseIcon()))
            ])));

    if (c.exitTap) {
      dialog = TapRegion(
          onTapOutside: (event) {
            c.hide();
          },
          child: dialog);
    }

    return FocusScope(
        node: c.focusNode,
        child: FadeTransition(
            opacity: c.bgAnimation,
            child: Container(
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

/*import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/home/home.dart';
import 'package:skribbl_client/widgets/dialog/dialog.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: () {
        var homeController = Get.find<HomeController>();

        if (homeController.hasCode) {
// #region Private room
          if (homeController.isPrivateRoomCodeValid) {
            // join private room
            // TODO: TEST JOINING PRIVATE ROOM
            PrivateGame.join(homeController.privateRoomCode);
            return;
          }
          // show dialog for invalid code room

          _dialog.show();
// #endregion

          return;
        }

        // otherwise join public game
        PublicGame.join();
      },
      color: const Color(0xff53e237),
      hoverColor: const Color(0xff38c41c),
      height: 54,
      child: Text('play_button'.tr,
          style: const TextStyle(
              fontSize: 32, shadows: [Shadow(color: Color(0x2b000000), offset: Offset(2, 2))])),
    );
  }

  static GameDialog? __dialog;
  // TODO: SHOW DIALOG FOR INVALID PRIVATE ROOM CODE
  static GameDialog get _dialog => __dialog ??= _WrongPrivateCodeDialog();
}

class _WrongPrivateCodeDialog extends GameDialog {
  _WrongPrivateCodeDialog()
      : super(
            title: () => 'dialog_title_error'.tr,
            content: Text('dialog_content_wrong_private_code'.tr));
}

class _WrongPrivateCodeWidget extends OverlayWidgetChild<GameDialog> {
  const _WrongPrivateCodeWidget();

  @override
  Widget build(BuildContext context) {
    return Text('dialog_content_wrong_private_code'.tr);
  }
}
*/