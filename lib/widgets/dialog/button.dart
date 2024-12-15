import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

abstract class GameDialogButtons extends Widget {
  const factory GameDialogButtons.row(
      {required List<GameDialogButtonContainer> children, double gap}) = _RowRenderObjectWidget;
//  const factory GameDialogButtons.column({required List<GameDialogButton> children}) = _Column;
  const GameDialogButtons({super.key});

  static TextStyle get textStyle => const TextStyle(
      fontSize: 15,
      fontVariations: [FontVariation.weight(800)],
      shadows: [Shadow(color: Color(0x90000000), offset: Offset(2.3, 2.3))]);
}

typedef OnTapCallback = Future<bool> Function(Future<bool> Function() onQuit);

class GameDialogButtonContainer extends ParentDataWidget<_ChildParentData> {
  const GameDialogButtonContainer({super.key, this.flex = 1.0, required super.child})
      : assert(flex > 0);
  final double flex;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as _ChildParentData;
    if (parentData.flex != flex) {
      parentData.flex = flex;
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => throw UnimplementedError();
}

abstract class GameDialogButtonChild extends StatelessWidget {
  const GameDialogButtonChild({super.key, this.onTap = GameDialogButtonChild.defaultOnTap});

  // static Future<bool> defaultOnTap(BuildContext context) =>
  //     OverlayWidget.of<GameDialog>(context).onQuit();

  static Future<bool> defaultOnTap(Future<bool> Function() onQuit) => onQuit();

  /// if null, the behavior will be `quit(context)` for default
  ///
  /// if not null, you can call `quit(context)` with the `quit` parameter
  final OnTapCallback onTap;
}

class OKayDialogButton extends GameDialogButtonChild {
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

// class _Column extends _Row {
//   const _Column({required super.children});
//   @override
//   Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: children);
// }

class _RowRenderObjectWidget extends MultiChildRenderObjectWidget implements GameDialogButtons {
  const _RowRenderObjectWidget({required super.children, this.gap = 10});
  // : assert(children.length > 1 || gap == 0, 'If children.length <= 1, gap must be 0');
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

    if (child == null) {
      size = const Size(0, 0);
      return;
    }

    // size
    var childWidthUnit = (constraints.minWidth - gap * (childCount - 1)) / childCount;
    double maxChildWidthUnit = childWidthUnit;
    double maxHeight = 0;
    late double flex;

    do {
      while (child != null) {
        flex = (child.parentData as _ChildParentData).flex;
        child.layout(
            BoxConstraints(minWidth: childWidthUnit * flex, minHeight: constraints.minHeight),
            parentUsesSize: true);
        maxChildWidthUnit = max(maxChildWidthUnit, child.size.width / flex);
        maxHeight = max(maxHeight, child.size.height);

        child = childAfter(child);
      }
    } while (maxChildWidthUnit > childWidthUnit);

    // position
    child = firstChild;
    double dx = 0;

    while (child != null) {
      (child.parentData as _ChildParentData).offset = Offset(dx, 0);

      dx += child.size.width + gap;
      child = childAfter(child);
    }

    size = Size(dx - gap, maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}

class _ChildParentData extends ContainerBoxParentData<RenderBox> {
  _ChildParentData({this.flex = 1});
  double flex;
}
