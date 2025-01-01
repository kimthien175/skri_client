part of 'buttons.dart';

abstract class GameDialogButtonChild extends StatelessWidget {
  const GameDialogButtonChild({super.key}); //, this.onTap = GameDialogButtonChild.defaultOnTap});

  // static Future<bool> defaultOnTap(BuildContext context) =>
  //     OverlayWidget.of<GameDialog>(context).onQuit();

  static Future<bool> defaultOnTap(Future<bool> Function() onQuit) => onQuit();

  /// if null, the behavior will be `quit(context)` for default
  ///
  /// if not null, you can call `quit(context)` with the `quit` parameter
  // final OnTapCallback onTap;
}

class _OKayButtonChild extends GameDialogButtonChild {
  const _OKayButtonChild();
  String get content => 'dialog_button_ok'.tr;

  static Future<bool> defaultOnTap(Future<bool> Function() onQuit) async {
    await onQuit();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return HoverButton(
        onTap: () {
          GameDialog controller = OverlayWidget.of<GameDialog>(context);

          if (controller.completer.isCompleted) return;

          GameDialogButton buttonParent =
              context.findAncestorWidgetOfExactType<GameDialogButton>()!;

          controller.completer
              .complete(buttonParent.onTap(() => controller.onQuit(controller.hide)));
        },
        constraints: const BoxConstraints(minHeight: 37.5),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.5),
            child: Text(content, style: GameDialogButtons.textStyle)));
  }
}

class _NoButtonChild extends _OKayButtonChild {
  const _NoButtonChild(); //{super.onTap = _NoButtonChild.defaultOnTap});

  static Future<bool> defaultOnTap(Future<bool> Function() onQuit) async {
    await onQuit();
    return false;
  }

  @override
  String get content => 'dialog_button_no'.tr;
}

class _YesButtonChild extends _OKayButtonChild {
  const _YesButtonChild(); //{super.key, super.onTap});

  @override
  String get content => 'dialog_button_yes'.tr;
}
