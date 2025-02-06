import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReportContentObjectWidget extends MultiChildRenderObjectWidget {
  const ReportContentObjectWidget({super.key, required super.children})
      : assert(children.length >= 3 && (children.length - 1) % 2 == 0);

  @override
  RenderObject createRenderObject(BuildContext context) => _ReportContentRenderObject();
}

class _ReportContentRenderObject extends RenderBox
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
    // title
    RenderBox title = firstChild!;
    title.layout(const BoxConstraints(), parentUsesSize: true);

    double maxWidth = max(title.size.width, constraints.minWidth);
    double maxHeight = title.size.height;

    // get max width

    late RenderBox checkBox;
    RenderBox? contentItem = childAfter(title);

    while (contentItem != null) {
      contentItem.layout(const BoxConstraints(), parentUsesSize: true);

      checkBox = childAfter(contentItem)!;
      checkBox.layout(const BoxConstraints(), parentUsesSize: true);

      maxHeight += max(contentItem.size.height, checkBox.size.height);
      maxWidth = max(maxWidth, contentItem.size.width + checkBox.size.width);

      contentItem = childAfter(checkBox);
    }

    double space = max(10, (constraints.minHeight - maxHeight) / 4);
    maxHeight += space * 4;

    size = Size(maxWidth, maxHeight);

    // set offset
    (title.parentData as _ParentData).offset = Offset((maxWidth - title.size.width) / 2, space);
    maxHeight -= space;
    while (checkBox != title) {
      (checkBox.parentData as _ParentData).offset =
          Offset(maxWidth - checkBox.size.width, maxHeight - checkBox.size.height);

      contentItem = childBefore(checkBox)!;
      (contentItem.parentData as _ParentData).offset =
          Offset(0, maxHeight - contentItem.size.height);

      maxHeight -= max(contentItem.size.height, checkBox.size.height);

      checkBox = childBefore(contentItem)!;
    }
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
