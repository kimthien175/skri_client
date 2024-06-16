import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SingleChild2DScrollView extends TwoDimensionalScrollView {
  const SingleChild2DScrollView(
      {super.key, required super.delegate, super.verticalDetails, super.horizontalDetails})
      : super(primary: false);
  @override
  Widget buildViewport(
          BuildContext context, ViewportOffset verticalOffset, ViewportOffset horizontalOffset) =>
      _TwoDimensionalViewport(
        verticalOffset: verticalOffset,
        verticalAxisDirection: verticalDetails.direction,
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: horizontalDetails.direction,
        delegate: delegate,
        mainAxis: mainAxis,
      );
}

class SingleChild2DDelegate extends TwoDimensionalChildDelegate {
  SingleChild2DDelegate({required this.child});
  final Widget child;
  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) => child;

  @override
  bool shouldRebuild(covariant SingleChild2DDelegate oldDelegate) => oldDelegate.child != child;
}

class _TwoDimensionalViewport extends TwoDimensionalViewport {
  const _TwoDimensionalViewport(
      {required super.verticalOffset,
      required super.verticalAxisDirection,
      required super.horizontalOffset,
      required super.horizontalAxisDirection,
      required super.delegate,
      required super.mainAxis});

  @override
  _RenderTwoDimensionalViewport createRenderObject(BuildContext context) =>
      _RenderTwoDimensionalViewport(
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          childManager: context as TwoDimensionalChildManager);

  @override
  void updateRenderObject(BuildContext context, RenderTwoDimensionalViewport renderObject) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class _RenderTwoDimensionalViewport extends RenderTwoDimensionalViewport {
  _RenderTwoDimensionalViewport(
      {required super.horizontalOffset,
      required super.horizontalAxisDirection,
      required super.verticalOffset,
      required super.verticalAxisDirection,
      required super.delegate,
      required super.mainAxis,
      required super.childManager});

  @override
  void layoutChildSequence() {
    var child = buildOrObtainChildFor(const ChildVicinity(xIndex: 0, yIndex: 0))!;

    child.layout(const BoxConstraints(), parentUsesSize: true);

    parentDataOf(child).layoutOffset = Offset(-horizontalOffset.pixels, -verticalOffset.pixels);

    verticalOffset.applyContentDimensions(0, child.size.height - viewportDimension.height);
    horizontalOffset.applyContentDimensions(0, child.size.width - viewportDimension.width);
  }
}
