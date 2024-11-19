import 'package:flutter/material.dart';

import 'dialog.dart';

// class GameDialogButtonsLayout extends StatelessWidget{
//   const GameDialogButtonsLayout({required String tag});
//   const GameDialogButtonsLayout.OK({required String tag});
//   @override
//   Widget build(BuildContext context) {
//     return GameDialogButton.OK(tag: )
//   }

// }

// // abstract class GameDialogButtonsLayout extends StatelessWidget {
// //   const GameDialogButtonsLayout({required this.children, super.key});
// //   const factory GameDialogButtonsLayout.column({required List<GameDialogButton> children}) =
// //       _GameDialogButtonsLayoutColumn;
// //   const factory GameDialogButtonsLayout.row({required List<GameDialogButton> children}) =
// //       _GameDialogButtonsLayoutRow;

// //   final List<GameDialogButton> children;
// // }

// class _GameDialogButtonsLayoutRow extends GameDialogButtonsLayout {
//   const _GameDialogButtonsLayoutRow({required super.children});

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: children);
//   }
// }

// class _GameDialogButtonsLayoutColumn extends GameDialogButtonsLayout {
//   const _GameDialogButtonsLayoutColumn({required super.children});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: children);
//   }
// }

// import 'package:skribbl_client/widgets/overlay/overlay.dart';

// abstract class GameDialogButtonsLayout extends PositionedOverlayWidget<GameDialog> {
//   const GameDialogButtonsLayout({super.key});
//   const factory GameDialogButtonsLayout.defaultOkay() = _GameDialogButtonsLayoutDefaultOkay;
//   const factory GameDialogButtonsLayout.row() = _GameDialogButtonsLayoutRow;
//   const factory GameDialogButtonsLayout.column() = _GameDialogButtonsLayoutColumn;
// }

// class _GameDialogButtonsLayoutDefaultOkay extends GameDialogButtonsLayout {
//   const _GameDialogButtonsLayoutDefaultOkay();

//   @override
//   Widget build(BuildContext context) {
//     return GameDialogButton.okay();
//   }
// }

// class _GameDialogButtonsLayoutRow extends GameDialogButtonsLayout {
//   const _GameDialogButtonsLayoutRow();

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: controller.buttons!);
//   }
// }

// class _GameDialogButtonsLayoutColumn extends GameDialogButtonsLayout {
//   const _GameDialogButtonsLayoutColumn();

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: controller.buttons!);
//   }
// }
