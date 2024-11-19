// import 'package:flutter/material.dart';
// import 'package:skribbl_client/utils/utils.dart';
// import 'package:skribbl_client/widgets/widgets.dart';

// typedef Callback = void Function(void Function() superCallback);

// /// take maximum width
// abstract class GameDialogButton extends OverlayWidgetChild<GameDialog> {
//   const GameDialogButton({super.key, this.onTap});

//   const factory GameDialogButton.okay({Key? key, Callback? onTap}) = _GameDialogButtonOkay;
//   // GameDialogButton.Cancel();
//   // GameDialogButton.Yes();
//   // GameDialogButton.No();

//   final Callback? onTap;
// }

// class _GameDialogButtonOkay extends GameDialogButton {
//   const _GameDialogButtonOkay({super.key, super.onTap});
//   @override
//   Widget build(BuildContext context) => LayoutBuilder(
//       builder: (context, constraints) => HoverButton(
//             width: constraints.maxWidth,
//             color: GlobalStyles.colorPanelButton,
//           ));
// }
