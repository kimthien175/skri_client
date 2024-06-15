// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'dart:math' as math;

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: TwoDimensionalGridView(
//         delegate: TwoDimensionalChildBuilderDelegate(
//             maxXIndex: 9,
//             maxYIndex: 9,
//             builder: (BuildContext context, ChildVicinity vicinity) {
//               return Container(
//                 color: vicinity.xIndex.isEven && vicinity.yIndex.isEven
//                     ? Colors.amber[50]
//                     : (vicinity.xIndex.isOdd && vicinity.yIndex.isOdd ? Colors.purple[50] : null),
//                 height: 200,
//                 width: 200,
//                 child: Center(child: Text('Row ${vicinity.yIndex}: Column ${vicinity.xIndex}')),
//               );
//             }),
//       ),
//     );
//   }
// }

// class TwoDimensionalGridView extends TwoDimensionalScrollView {
//   const TwoDimensionalGridView({
//     super.mainAxis = Axis.vertical,
//     super.verticalDetails = const ScrollableDetails.vertical(),
//     super.horizontalDetails = const ScrollableDetails.horizontal(),
//     required TwoDimensionalChildBuilderDelegate delegate,
//     super.cacheExtent,
//   }) : super(delegate: delegate);

//   @override
//   Widget buildViewport(
//     BuildContext context,
//     ViewportOffset verticalOffset,
//     ViewportOffset horizontalOffset,
//   ) {
//     return TwoDimensionalGridViewport(
//       horizontalOffset: horizontalOffset,
//       horizontalAxisDirection: horizontalDetails.direction,
//       verticalOffset: verticalOffset,
//       verticalAxisDirection: verticalDetails.direction,
//       mainAxis: mainAxis,
//       delegate: delegate as TwoDimensionalChildBuilderDelegate,
//       cacheExtent: cacheExtent,
//       clipBehavior: clipBehavior,
//     );
//   }
// }

// class TwoDimensionalGridViewport extends TwoDimensionalViewport {
//   const TwoDimensionalGridViewport({
//     super.key,
//     required super.verticalOffset,
//     required super.verticalAxisDirection,
//     required super.horizontalOffset,
//     required super.horizontalAxisDirection,
//     required TwoDimensionalChildBuilderDelegate super.delegate,
//     required super.mainAxis,
//     super.cacheExtent,
//     super.clipBehavior = Clip.hardEdge,
//   });

//   @override
//   RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
//     return RenderTwoDimensionalGridViewport(
//       horizontalOffset: horizontalOffset,
//       horizontalAxisDirection: horizontalAxisDirection,
//       verticalOffset: verticalOffset,
//       verticalAxisDirection: verticalAxisDirection,
//       mainAxis: mainAxis,
//       delegate: delegate as TwoDimensionalChildBuilderDelegate,
//       childManager: context as TwoDimensionalChildManager,
//       cacheExtent: cacheExtent,
//       clipBehavior: clipBehavior,
//     );
//   }

//   @override
//   void updateRenderObject(
//     BuildContext context,
//     RenderTwoDimensionalGridViewport renderObject,
//   ) {
//     renderObject
//       ..horizontalOffset = horizontalOffset
//       ..horizontalAxisDirection = horizontalAxisDirection
//       ..verticalOffset = verticalOffset
//       ..verticalAxisDirection = verticalAxisDirection
//       ..mainAxis = mainAxis
//       ..delegate = delegate
//       ..cacheExtent = cacheExtent
//       ..clipBehavior = clipBehavior;
//   }
// }

// class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
//   RenderTwoDimensionalGridViewport({
//     required super.horizontalOffset,
//     required super.horizontalAxisDirection,
//     required super.verticalOffset,
//     required super.verticalAxisDirection,
//     required TwoDimensionalChildBuilderDelegate delegate,
//     required super.mainAxis,
//     required super.childManager,
//     super.cacheExtent,
//     super.clipBehavior = Clip.hardEdge,
//   }) : super(delegate: delegate);

//   @override
//   void layoutChildSequence() {
//     // // Subclasses only need to set the normalized layout offset. The super
//     // // class adjusts for reversed axes.
//     // parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);

//     // verticalOffset.applyContentDimensions(
//     //   0.0,
//     //   clampDouble(verticalExtent - viewportDimension.height, 0.0, double.infinity),
//     // );
//     // horizontalOffset.applyContentDimensions(
//     //   0.0,
//     //   clampDouble(horizontalExtent - viewportDimension.width, 0.0, double.infinity),
//     // );
//     // Super class handles garbage collection too!
//   }
// }
