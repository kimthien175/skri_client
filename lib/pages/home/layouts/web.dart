import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/footer/triangle.dart';
import 'package:cd_mobile/pages/home/widgets/create_private_room_button.dart';
import 'package:cd_mobile/pages/home/widgets/lang_selector.dart';
import 'package:cd_mobile/pages/home/widgets/name_input.dart';
import 'package:cd_mobile/pages/home/widgets/play_button.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:cd_mobile/widgets/measure_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebController extends GetxController {
  final RxBool isHeightFit = false.obs;
  final RxBool isWidthFit = false.obs;
  void processLayout() {
    var homeController = Get.find<HomeController>();
    var mainSize = homeController.mainContentKey.currentContext?.size;
    var footerSize = homeController.footerKey.currentContext?.size;
    if (mainSize != null && footerSize != null) {
      isHeightFit.value = mainSize.height + footerSize.height <= Get.height;
      isWidthFit.value = Footer.webWidth <= Get.width;
    } else {
      isHeightFit.value = false;
      isWidthFit.value = false;
    }
  }

  final horizontalScrollController = ScrollController();
  final verticalScrollController = ScrollController();

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }
}

class Web extends GetView<WebController> {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WebController());
    var homeController = Get.find<HomeController>();
    var mainContent =
        Column(key: homeController.mainContentKey, mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 25),
      const Logo(Logo.clearUrl),
      const SizedBox(height: 10),
      const RandomAvatars(),
      const SizedBox(height: 40),
      Container(
          padding: PanelStyles.padding,
          decoration: PanelStyles.webDecoration,
          width: PanelStyles.width,
          child: const Column(
            children: [
              Row(children: [NameInput(), LangSelector()]),
              AvatarEditor(),
              PlayButton(),
              SizedBox(height: 10),
              CreatePrivateRoomButton(),
            ],
          )),
      const SizedBox(height: 20)
    ]);

    var footer = Column(
      key: homeController.footerKey,
      mainAxisSize: MainAxisSize.min,
      children: const [Triangle(), Footer()],
    );

    return Obx(() {
      // print('____');
      // print('width ${controller.isWidthFit.value}');
      // print('height ${controller.isHeightFit.value}');
      return MeasureSize(
          onChange: controller.processLayout,
          child: controller.isWidthFit.value
              ? (controller.isHeightFit.value
                  ? ClipRect(
                      child: Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [Positioned(top: 0, child: mainContent), footer],
                    ))
                  : Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: controller.verticalScrollController,
                      child: SingleChildScrollView(
                          controller: controller.verticalScrollController,
                          child: ClipRect(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [mainContent, footer],
                          )))))
              : (controller.isHeightFit.value
                  ? Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: controller.horizontalScrollController,
                      child: SingleChildScrollView(
                          controller: controller.horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [Positioned(top: 0, child: mainContent), footer],
                          )))
                  : _SingleChildTwoAxisScrollView(
                      verticalController: controller.verticalScrollController,
                      horizontalController: controller.horizontalScrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [mainContent, footer],
                      ))));
    }

        // _SingleChildTwoDimensionalScrollView.builder(
        //     child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [mainContent, footer],
        //   ))
        // Scrollbar(
        //     thumbVisibility: true,
        //     trackVisibility: true,
        //     controller: controller.verticalScrollController,
        //     child: Scrollbar(
        //         thumbVisibility: true,
        //         trackVisibility: true,
        //         controller: controller.horizontalScrollController,
        //         child: SingleChildScrollView(
        //             controller: controller.horizontalScrollController,
        //             scrollDirection: Axis.horizontal,
        //             child: SingleChildScrollView(
        //                 controller: controller.verticalScrollController,
        //                 child: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [mainContent, footer],
        //                 )))))
        );
  }
}

class _SingleChildTwoAxisScrollController extends GetxController {
  _SingleChildTwoAxisScrollController(
      {ScrollController? verticalController, ScrollController? horizontalController}) {
    if (verticalController == null) {
      this.verticalController = ScrollController();
      onDisposeCallbacks.add(
        () {
          this.verticalController.dispose();
        },
      );
    } else {
      this.verticalController = verticalController;
    }

    if (horizontalController == null) {
      this.horizontalController = ScrollController();
      onDisposeCallbacks.add(
        () {
          this.horizontalController.dispose();
        },
      );
    } else {
      this.horizontalController = horizontalController;
    }
  }
  final RxDouble dx = 0.0.obs;
  final RxDouble dy = 0.0.obs;
  late final ScrollController verticalController;
  late final ScrollController horizontalController;
  final List<void Function()> onDisposeCallbacks = [];

  @override
  void dispose() {
    for (var callback in onDisposeCallbacks) {
      callback();
    }
    super.dispose();
  }
}

class _SingleChildTwoAxisScrollView extends GetView<_SingleChildTwoAxisScrollController> {
  const _SingleChildTwoAxisScrollView(
      {required this.child, this.verticalController, this.horizontalController});
  final Widget child;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;
  @override
  Widget build(BuildContext context) {
    Get.put(_SingleChildTwoAxisScrollController(
        verticalController: verticalController, horizontalController: horizontalController));

    return Scrollbar(
        controller: controller.verticalController,
        child: Scrollbar(
            controller: controller.horizontalController,
            child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  controller.dy.value += details.delta.dy;
                },
                onHorizontalDragUpdate: (details) {
                  controller.dx.value += details.delta.dx;
                },
                child: Obx(() => ClipRect(
                    clipBehavior: Clip.antiAlias,
                    clipper: _Clipper(controller.dx.value, controller.dy.value),
                    child: child)))));
  }
}

class _Clipper extends CustomClipper<Rect> {
  _Clipper(this.left, this.top);
  final double left;
  final double top;
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(left, top, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

// class _SingleChildTwoDimensionalScrollView extends TwoDimensionalScrollView {
//   static _SingleChildTwoDimensionalScrollView builder({required Widget child}) {
//     return _SingleChildTwoDimensionalScrollView._internal(
//         delegate: _TwoDimensionalChildDelegate(child), child: child);
//   }

//   const _SingleChildTwoDimensionalScrollView._internal({
//     required this.child,
//     required super.delegate,
//   });
//   final Widget child;
//   @override
//   Widget buildViewport(
//           BuildContext context, ViewportOffset verticalOffset, ViewportOffset horizontalOffset) =>
//       // ClipRect(
//       //     child: Transform.translate(
//       //         offset: Offset(-horizontalOffset.pixels, -verticalOffset.pixels)));
//       _TwoDimensionalViewport(
//         verticalOffset: verticalOffset,
//         verticalAxisDirection: verticalDetails.direction,
//         horizontalOffset: horizontalOffset,
//         horizontalAxisDirection: horizontalDetails.direction,
//         delegate: delegate,
//         mainAxis: mainAxis,
//       );
// }

// class _TwoDimensionalChildDelegate extends TwoDimensionalChildDelegate {
//   _TwoDimensionalChildDelegate(Widget child) {
//     this.child = Container(key: key, child: child);
//   }
//   late final Widget child;
//   GlobalKey key = GlobalKey();
//   @override
//   Widget? build(BuildContext context, covariant ChildVicinity vicinity) => child;

//   @override
//   bool shouldRebuild(covariant _TwoDimensionalChildDelegate oldDelegate) =>
//       oldDelegate.child != child;
// }

// class _TwoDimensionalViewport extends TwoDimensionalViewport {
//   const _TwoDimensionalViewport(
//       {required super.verticalOffset,
//       required super.verticalAxisDirection,
//       required super.horizontalOffset,
//       required super.horizontalAxisDirection,
//       required super.delegate,
//       required super.mainAxis});

//   @override
//   RenderTwoDimensionalViewport createRenderObject(BuildContext context) =>
//       _RenderTwoDimensionalViewport(
//           horizontalOffset: horizontalOffset,
//           horizontalAxisDirection: horizontalAxisDirection,
//           verticalOffset: verticalOffset,
//           verticalAxisDirection: verticalAxisDirection,
//           delegate: delegate,
//           mainAxis: mainAxis,
//           childManager: context as TwoDimensionalChildManager);

//   @override
//   void updateRenderObject(BuildContext context, RenderTwoDimensionalViewport renderObject) {
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

// class _RenderTwoDimensionalViewport extends RenderTwoDimensionalViewport {
//   _RenderTwoDimensionalViewport(
//       {required super.horizontalOffset,
//       required super.horizontalAxisDirection,
//       required super.verticalOffset,
//       required super.verticalAxisDirection,
//       required super.delegate,
//       required super.mainAxis,
//       required super.childManager});

//   @override
//   void layoutChildSequence() {
//     childManager.buildOrObtainChildFor()
//     var keyContext = (delegate as _TwoDimensionalChildDelegate).key.currentContext;

//     if (keyContext == null || keyContext.size == null) {
//       verticalOffset.applyContentDimensions(0.0, 0.0);
//       horizontalOffset.applyContentDimensions(0.0, 0.0);
//       return;
//     }

// child

//     verticalOffset.applyContentDimensions(0.0, keyContext.size!.height - viewportDimension.height);
//     horizontalOffset.applyContentDimensions(
//       0.0,
//       keyContext.size!.width - viewportDimension.width,
//     );
//   }
// }
