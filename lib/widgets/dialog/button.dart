import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

abstract class GameDialogButtons extends StatelessWidget {
  const factory GameDialogButtons.okay({OnTapCallback onTap}) = _OKButtons;
  const factory GameDialogButtons.row({required List<GameDialogButton> children}) = _Row;
  const factory GameDialogButtons.column({required List<GameDialogButton> children}) = _Column;
  const GameDialogButtons({super.key});

  static TextStyle get textStyle => const TextStyle(
      fontSize: 15,
      fontVariations: [FontVariation.weight(800)],
      shadows: [Shadow(color: Color(0x90000000), offset: Offset(2.3, 2.3))]);
}

typedef OnTapCallback = Future<bool> Function(Future<bool> Function() onQuit);

/// take maximum width
abstract class GameDialogButton extends StatelessWidget {
  const GameDialogButton({super.key, this.onTap = GameDialogButton.defaultOnTap});

  // static Future<bool> defaultOnTap(BuildContext context) =>
  //     OverlayWidget.of<GameDialog>(context).onQuit();

  static Future<bool> defaultOnTap(Future<bool> Function() onQuit) => onQuit();

  /// if null, the behavior will be `quit(context)` for default
  ///
  /// if not null, you can call `quit(context)` with the `quit` parameter
  final OnTapCallback onTap;
}

class OKayDialogButton extends GameDialogButton {
  const OKayDialogButton({super.key, super.onTap});
  String get content => 'dialog_button_ok'.tr;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
        onTap: () {
          GameDialog controller = OverlayWidget.of(context);

          controller.completer.complete(onTap(() => controller.onQuit(controller.hide)));
        },
        constraints: const BoxConstraints(minHeight: 37.5),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.5),
            child: Text(content, style: GameDialogButtons.textStyle)));
  }
}

class NoDialogButton extends OKayDialogButton {
  const NoDialogButton({super.key, super.onTap = NoDialogButton.defaultOnTap});

  static Future<bool> defaultOnTap(Future<bool> Function() onQuit) async {
    await onQuit();
    return false;
  }

  @override
  String get content => 'dialog_button_no'.tr;
}

class YesDialogButton extends OKayDialogButton {
  const YesDialogButton({super.key, super.onTap});

  @override
  String get content => 'dialog_button_yes'.tr;
}

class _OKButtons extends GameDialogButtons {
  const _OKButtons({this.onTap = GameDialogButton.defaultOnTap});
  final OnTapCallback onTap;
  @override
  Widget build(BuildContext context) => OKayDialogButton(onTap: onTap);
}

class _Row extends GameDialogButtons {
  const _Row({required this.children});
  final List<GameDialogButton> children;

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty, 'children must be not empty');

    return _RowRenderObjectWidget(gap: 10, children: children);
  }
}

class _Column extends _Row {
  const _Column({required super.children});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: children);
}

class _RowRenderObjectWidget extends MultiChildRenderObjectWidget {
  const _RowRenderObjectWidget({required super.children, this.gap = 0});
  final double gap;
  @override
  RenderObject createRenderObject(BuildContext context) => _RowRenderObject(gap: gap);
  @override
  void updateRenderObject(BuildContext context, _RowRenderObject renderObject) {
    renderObject.gap = gap;
  }
}

class _RowRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ChildParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ChildParentData> {
  _RowRenderObject({required this.gap});
  double gap;
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ChildParentData) {
      child.parentData = _ChildParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;

    if (child == null) return;

    if (childCount == 1) {
      child.layout(BoxConstraints(minWidth: constraints.minWidth));
      (child.parentData as _ChildParentData).offset = const Offset(0, 0);

      size = child.size;

      return;
    }

    var childWidth = (constraints.minWidth - gap * (childCount - 1)) / childCount;

    child.layout(BoxConstraints(minWidth: childWidth), parentUsesSize: true);
    (child.parentData as _ChildParentData).offset = const Offset(0, 0);
    double dx = child.size.width + gap;

    var finalHeight = child.size.height;
    child = childAfter(child);

    while (child != null) {
      child.layout(BoxConstraints(minWidth: childWidth), parentUsesSize: true);
      (child.parentData as _ChildParentData).offset = Offset(dx, 0);
      dx += child.size.width + gap;

      child = childAfter(child);
    }

    size = Size(dx - gap, finalHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}

class _ChildParentData extends ContainerBoxParentData<RenderBox> {}
