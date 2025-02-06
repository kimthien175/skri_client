import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DialogRenderObjectWidget extends MultiChildRenderObjectWidget {
  const DialogRenderObjectWidget({super.key, required super.children})
      : assert(children.length == 3 || children.length == 2);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _DialogRenderObject();
  }
}

class _DialogRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ParentData> {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  @override
  void performLayout() {
    //#region title
    RenderBox title = firstChild!;
    title.layout(const BoxConstraints(), parentUsesSize: true);
    (title.parentData as _ParentData).offset = const Offset(0, 0);

    double maxWidth = max(title.size.width, constraints.minWidth);
    double height = title.size.height;
    //#endregion

    //#region content
    RenderBox content = childAfter(title)!;
    content.layout(BoxConstraints(minWidth: constraints.minWidth), parentUsesSize: true);

    maxWidth = max(maxWidth, content.size.width);
    height += content.size.height;
    //#endregion

    // buttons
    RenderBox? buttons = childAfter(content);
    if (buttons != null) {
      buttons.layout(BoxConstraints(minWidth: maxWidth), parentUsesSize: true);

      height += buttons.size.height;
      maxWidth = max(maxWidth, buttons.size.width);
    }

    //#region position

    (content.parentData as _ParentData).offset =
        Offset((maxWidth - content.size.width) / 2, title.size.height);

    var finalHeight = max(height, constraints.minHeight);

    if (buttons != null) {
      (buttons.parentData as _ParentData).offset = Offset(0, finalHeight - buttons.size.height);
    }
    //#endregion

    // set size
    size = Size(maxWidth, finalHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = firstChild;
    while (child != null) {
      if (child.hitTest(result, position: position - (child.parentData as _ParentData).offset)) {
        return true;
      }
      child = childAfter(child);
    }

    return false;
  }
}

class _ParentData extends ContainerBoxParentData<RenderBox> {}
