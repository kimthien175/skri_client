import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

abstract class GameDialogButtons extends StatelessWidget {
  const factory GameDialogButtons.okay({OnTapCallback? onTap}) = _OKButtons;
  const factory GameDialogButtons.row({required List<GameDialogButton> children}) = _Row;
  const factory GameDialogButtons.column({required List<GameDialogButton> children}) = _Column;
  const GameDialogButtons({super.key});

  static TextStyle get textStyle => const TextStyle(
      fontSize: 15,
      fontVariations: [FontVariation.weight(800)],
      shadows: [Shadow(color: Color(0x90000000), offset: Offset(2.3, 2.3))]);
}

typedef OnTapCallback = Future<bool> Function(Future<bool> Function() quit);

/// take maximum width
abstract class GameDialogButton extends StatelessWidget {
  const GameDialogButton({super.key, this.onTap});
  Future<bool> quit(BuildContext context) => OverlayWidget.of<GameDialog>(context).hide();

  /// if null, the behavior will be `quit(context)` for default
  ///
  /// if not null, you can call `quit(context)` with the `quit` parameter
  final OnTapCallback? onTap;
}

class OKayDialogButton extends GameDialogButton {
  const OKayDialogButton({super.key, super.onTap});
  String get content => 'dialog_button_ok'.tr;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (ct, constraints) => HoverButton(
            onTap: onTap == null
                ? () {
                    OverlayWidget.of<GameDialog>(context).completer!.complete(quit(context));
                  }
                : () {
                    OverlayWidget.of<GameDialog>(context)
                        .completer!
                        .complete(onTap!(() => quit(context)));
                  },
            height: 37.5,
            width: constraints.maxWidth,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.5),
                child: Text(content, style: GameDialogButtons.textStyle))));
  }
}

class NoDialogButton extends GameDialogButton {
  const NoDialogButton({super.key, super.onTap});

  Future<bool> defaultOnTap(BuildContext context) async {
    await quit(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (ct, constraints) => HoverButton(
            onTap: onTap == null
                ? () {
                    OverlayWidget.of<GameDialog>(context)
                        .completer!
                        .complete(defaultOnTap(context));
                  }
                : () {
                    OverlayWidget.of<GameDialog>(context)
                        .completer!
                        .complete(onTap!(() => quit(context)));
                  },
            height: 37.5,
            width: constraints.maxWidth,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.5),
                child: Text('dialog_button_no'.tr, style: GameDialogButtons.textStyle))));
  }
}

class YesDialogButton extends OKayDialogButton {
  const YesDialogButton({super.key, super.onTap});

  @override
  String get content => 'dialog_button_yes'.tr;
}

class _OKButtons extends GameDialogButtons {
  const _OKButtons({this.onTap});
  final OnTapCallback? onTap;
  @override
  Widget build(BuildContext context) => OKayDialogButton(onTap: onTap);
}

class _Row extends GameDialogButtons {
  const _Row({required this.children});
  final List<GameDialogButton> children;

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty, 'children must be not empty');
    late List<Widget> finalChildren;

    if (children.length == 1) {
      finalChildren = children;
    } else {
      finalChildren = [];
      // add spacer between children except the last child
      for (int i = 0; i < children.length - 1; i++) {
        finalChildren.add(Expanded(child: children[i]));
        finalChildren.add(const SizedBox(width: 10));
      }
      finalChildren.add(Expanded(child: children.last));
    }

    return Row(
        //  mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: finalChildren);
  }
}

class _Column extends _Row {
  const _Column({required super.children});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: children);
}
