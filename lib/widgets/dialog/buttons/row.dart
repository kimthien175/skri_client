part of 'buttons.dart';

class RowRenderObjectWidget extends MultiChildRenderObjectWidget {
  const RowRenderObjectWidget({super.key, required List<GameDialogButton> children, this.gap = 10})
      : super(children: children);
  // : assert(children.length > 1 || gap == 0, 'If children.length <= 1, gap must be 0');
  final double gap;
  @override
  RenderObject createRenderObject(BuildContext context) => _RowRenderObject(gap: gap);
  @override
  // ignore: library_private_types_in_public_api
  void updateRenderObject(BuildContext context, _RowRenderObject renderObject) {
    renderObject.gap = gap;
  }
}

class _RowRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ButtonParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ButtonParentData> {
  _RowRenderObject({required double gap}) : _gap = gap;
  double _gap;

  double get gap => _gap;
  set gap(double value) {
    if (value != gap) {
      _gap = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ButtonParentData) {
      child.parentData = _ButtonParentData();
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
    double maxChildWidthUnit = (constraints.minWidth - gap * (childCount - 1)) / childCount;
    double childWidthUnit;
    double maxHeight = 0;
    late double flex;

    do {
      childWidthUnit = maxChildWidthUnit;
      while (child != null) {
        flex = (child.parentData as _ButtonParentData).flex;
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
      (child.parentData as _ButtonParentData).offset = Offset(dx, 0);

      dx += child.size.width + gap;
      child = childAfter(child);
    }

    size = Size(dx - gap, maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = firstChild;
    while (child != null) {
      if (child.hitTest(result,
          position: position - (child.parentData as _ButtonParentData).offset)) {
        return true;
      }

      child = childAfter(child);
    }
    return false;
  }
}
