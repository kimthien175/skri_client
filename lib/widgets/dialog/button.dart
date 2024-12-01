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

typedef OnTapCallback = Future<void> Function(Future<bool> Function() quit);

/// take maximum width
abstract class GameDialogButton extends StatelessWidget {
  const GameDialogButton({super.key, this.onTap});
  Future<bool> quit(BuildContext context) => OverlayWidget.of<GameDialog>(context).hide();

  /// if null, the behavior will be `quit(context)` for default
  ///
  /// if not null, you can call `quit(context)` with the `quit` parameter
  final OnTapCallback? onTap;
}

class _OKButton extends GameDialogButton {
  const _OKButton({super.onTap});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (ct, constraints) => HoverButton(
            onTap: onTap == null
                ? () {
                    quit(context);
                  }
                : () {
                    onTap!(() async => quit(context));
                  },
            height: 37.5,
            width: constraints.maxWidth,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.5),
                child: Text('dialog_button_ok'.tr, style: GameDialogButtons.textStyle))));
  }
}

class _OKButtons extends GameDialogButtons {
  const _OKButtons({this.onTap});
  final OnTapCallback? onTap;
  @override
  Widget build(BuildContext context) => _OKButton(onTap: onTap);
}

class _Row extends GameDialogButtons {
  const _Row({required this.children});
  final List<GameDialogButton> children;

  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children);
}

class _Column extends _Row {
  const _Column({required super.children});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: children);
}
